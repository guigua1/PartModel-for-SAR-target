function [parts] = genPart(nodes)

NoN = length(nodes);

parts(1).nodes = []; count = 1;
parts(1).confidence = 0;

n2part = zeros(NoN);

for ii = 1:NoN
    nbrs = nodes(ii).nbrs;
    if isempty(nbrs)
        % isolated node
        parts(count).nodes = ii;
        parts(count).type = 's';
        n2part(ii, ii) = count;
        count = count + 1;
    else
        % find connected nodes
        for jj = nbrs'
            if n2part(ii, jj) == 0
                [confidence, o, len] = isPart(nodes(ii), nodes(jj));
                if confidence > 0
                    parts(count).nodes = [ii, jj];
                    parts(count).o = o;
                    parts(count).confidence = confidence / len;
                    parts(count).type = 'p';
                    parts(count).len = len;
                    n2part(ii, jj) = count;
                    n2part(jj, ii) = count;
                    count = count + 1;
                else
                    n2part(ii, jj) = -1;
                    n2part(jj, ii) = -1;
                end
            end
        end
    end
end

redundant_part = [];
for ii = 1:NoN
%     zoomIn(nodes(ii).bbx);
    node = find(n2part(:, ii) > 0);
    if length(node) < 2
        continue;
    end
    q = n2part(ii,node);
    all_o = [parts(q).o];
    for jj = unique(all_o)
        same_o = node(all_o == jj);
        if length(same_o) > 1
            % parts in the same direction
            same_p = q(all_o == jj);
            union_part = unique([parts(same_p).nodes]);
%             inner_order = nodeOrder(nodes, union_part);
            merge_p = min(same_p);
            parts(merge_p).nodes = union_part;
            parts(merge_p).confidence = sum([parts(same_p).confidence]);
            parts(merge_p).len = sum([parts(same_p).len]);
            n2part(ii, same_o) = merge_p;
            n2part(same_o, ii) = merge_p;
            redundant_part = [redundant_part, setdiff(same_p, merge_p)];
            
%             centers = reshape([nodes(union_part(inner_order)).center], [], 2);
%             plot(centers(:,1), centers(:,2), '-og', 'LineWidth', 3);
            
        end
    end
end

for ii = 1:NoN
    q = unique(n2part(ii, n2part(:,ii)>0));
    if length(q) >2
%         zoomIn(nodes(ii).bbx);
        cc = [parts(q).confidence];
        [~, idx] = sort(cc, 'descend');
        redundant_part = [redundant_part, q(idx(3:end))];
    end
end

parts(unique(redundant_part)) = [];

for ii = 1:length(parts)
    
    node = nodes(parts(ii).nodes);
    centers = reshape([node.center],2,[])';
    radius = [node.radius];
    wid = mean(radius);
    endp = centers;
    if parts(ii).type == 's'
        len = 0;
        rbbx = R2BBx(node.bbx, 'r');
    else
        if length(node) == 2
            len = parts(ii).len;
            direc = diff(endp);
            direc = direc / norm(direc);
        else
            endp = centers([1, end], :);
            len = norm(diff(endp));
            centroid = radius * centers / sum(radius);
            d = polyfit(centers(:,1), centers(:,2), 1);
            direc = [1, d(1)] / (sqrt(1+d(1)^2));         
            endp(:,2) = polyval(d, endp(:,1));
            bias = (centroid - endp(1,:));
            bias = bias - [bias * direc'] * direc;
            endp = endp + [1;1] * bias;
        end
        if direc(1) == 0
            direc = [1, 0];
        elseif direc(1) < 0
            direc = -direc;
            endp(2:-1:1, :)  = endp;
        end
        direc_v = [-direc(2), direc(1)];
        
        parts(ii).direc = direc;
        parts(ii).direc_v = direc_v;
        ul_corner = endp(1, :) - wid * (direc_v + direc);
        rbbx = getRBBx(ul_corner, direc, direc_v, len+2*wid, 2*wid);
    end
    showRBBx(rbbx);
%     pause();
    parts(ii).centers = centers;
    parts(ii).endp = endp;
    parts(ii).l = len;
    parts(ii).rbbx = rbbx;
    parts(ii).w = wid * 2;
end

%% figure
global infigure;
if infigure
    figure(gcf); hold on;
    for ii = 1:length(parts);
        if parts(ii).type == 'p'
        centers = reshape([nodes(parts(ii).nodes).center], 2, [])';
        plot(centers(:,1), centers(:,2), '-b', 'LineWidth', 2);
        end
    end
    axis image; hold off;
end

%% inner functions
%   -----Are two node in part? 
function [confidence, o_p, part_len] = isPart(n_i, n_j)

global T_s T_c infigure;

center_line = n_i.center - n_j.center;
part_len = norm(center_line);

o_ij = eighthAngle(center_line);
o_ji = eighthAngle(-center_line);
o_p = min(o_ij, o_ji);

C_rho = n_i.a_mom(o_ij)  * n_j.a_mom(o_ji);

C_s = maxRatio(n_i.mu, n_j.mu) * maxRatio(n_i.sigma, n_j.sigma) ; %* maxRatio(n_i.radius, n_j.radius);

confidence = max((T_c - C_rho) / (T_c), 0) * max((T_s - C_s) / (T_s - 1), 0);

if confidence == 0
   if infigure
        figure(gcf); hold on;
        line([n_i.center(1); n_j.center(1)], [n_i.center(2); n_j.center(2)], 'Color', [1 0 0], 'LineWidth', 1);
        hold off;
   end
end

%   -----order nodes in the same part
function orders = nodeOrder(nodes, part_n)
% use origional distance
node_position = reshape([nodes(part_n).center], 2, []);
[~,orders] = sort(sum(node_position.^2));