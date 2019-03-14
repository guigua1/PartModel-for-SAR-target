function [Nodes] = findINode(I_t)

global mv2Nbr NBR labels;
% neighborhood size: 4- or 8-
if NBR == 4
    mv2Nbr = [ 0  1;
                           1  0;
                           0 -1;
                         -1  0];
else
    mv2Nbr = [-1  1; 
                            0  1;
                            1  1;
                            1  0;
                            1 -1;
                            0 -1;
                          -1 -1;
                          -1  0];
end

conns = bwconncomp(I_t > 0, NBR);

Nodes = [];

for ii = 1:conns.NumObjects
    % find the extremal points in a connected region, with neighbors in mv2Nghb.
    pixel_list = conns.PixelIdxList{ii};
    
    if length(pixel_list) <= 5
        continue;
    end
%     disp(length(pixel_list));
    % initialize label for each pixel
    labels(pixel_list) = pixel_list;
    
    nodes = dfsMax(I_t, pixel_list);
    
    Nodes = [Nodes, nodes];
end

% squeeze labels
for ii = 1:length(Nodes)
    labels(Nodes(ii).lbl) = Nodes(ii).lbl;
    labels(labels == Nodes(ii).lbl) = ii;
end

function nodes = dfsMax(Img, pixel_list)

global mv2Nbr labels m n;

for ii = pixel_list'
    % if the label of pixel is itself, find maximum point
    if labels(ii) == ii;
        % dfs
        path = [ii];
        while true
            if labels(path(end)) == -1
                labels(path(1:end-1)) = path(end);
                break;
            elseif labels(path(end)) ~= path(end)
                labels(path(1:end-1)) = labels(path(end));
                break;
            end
            
            [idx, idy] = ind2sub([m, n], path(end));
            nbrs = bsxfun(@plus, [idx, idy], mv2Nbr);
            nbrs = nbrs(all(nbrs > 0,2) & nbrs(:,1) < m & nbrs(:,2) < n, :);
            nbrs = [sub2ind([m, n], nbrs(:,1), nbrs(:,2)); path(end)];
            max_I = max(Img(nbrs));
            
            loc = Img(nbrs) == max_I;
            loc = nbrs(loc);
            
            switch length(loc)
                case 1
                    if loc == path(end)
                        labels(path) = path(end);
                        labels(loc) = -1;
                        break;
                    else
                        path(end+1) = loc;
                    end
                otherwise
                    lock = true;
                    for jj = loc'
                        if ~ismember(jj, path);
                            path(end+1) = jj;
                            lock = false;
                            break;
                        end
                    end
                    if lock
                        iloc = Img(path) == Img(loc(1));
                        [cenX, cenY] = ind2sub([m, n], path(iloc));
                        cenX = round(mean(cenX)); cenY = round(mean(cenY));
                        iloc = sub2ind([m, n], cenX, cenY);
                        if ~ismember(iloc, path)
                            [~,iloc] = min(abs(path - iloc));
                            iloc = path(iloc);
                        end
                        
                        labels(path) = iloc;
                        labels(iloc) = -1;
                        break;
                    end
            end
        end
    end
end

query = labels(pixel_list);
node_ids = find(query == -1);
if isempty(node_ids)
    nodes = [];
    return;
end

nodes(length(node_ids)).lbl = [];
for ii = 1:length(node_ids)
    nodes(ii).lbl = pixel_list(node_ids(ii));
    nodes(ii).pixel_list = pixel_list(query == pixel_list(node_ids(ii)));
    nodes(ii).len = length(nodes(ii).pixel_list);
end
