function [centroids, radius, trees] = findEnd(Map)

global mv2Nghb m n Nbr;
[m,n] = size(Map);
if Nbr == 4
    mv2Nghb = [ 0  1;
                1  0;
                0 -1;
               -1  0];
else
    mv2Nghb = [-1  1;
                0  1;
                1  1;
                1  0;
                1 -1;
                0 -1;
               -1 -1;
               -1  0];
end

global book;
book = zeros(m,n);
trees = {};centroids = {}; radius = centroids;count = 0;
for ii = 1:m
    for jj = 1:n
        if Map(ii,jj) ~= 0 && book(ii,jj) ~= 1
            tree = bfs(Map,ii,jj);
            if length(tree) > 4
                count = count + 1;
                trees{count} = tree;
            end
        end
    end
end

global labels;
labels = zeros(m,n);

for ii = 1:count
    % find the extremal point in the tree, neighbors used mv2Nghb.
    tree = trees{ii};
    % unionSet achieve
    for kk = 1:length(tree)
        labels(tree(kk,1),tree(kk,2)) = kk;
    end
    for kk = 1:length(tree)
        % set the label as the label of max in the neighbors
        neighMaxLabel(Map,tree,kk);
    end
    % find connection and centroid
    singTree = [];
    for kk = 1:length(tree)
        pos = labels(tree(kk,1),tree(kk,2));
        % makesure maxLabel is the local maximization endnode
        while (pos ~= 0) && (labels(tree(pos,1),tree(pos,2)) ~= pos)
            mysource = pos;
            pos = labels(tree(pos,1),tree(pos,2));
            if (pos ~= 0) && (labels(tree(pos,1),tree(pos,2)) == mysource)
                break;
            end
            disp(num2str(pos));
        end
        if pos == 0
            continue;
        end
        % extract the local maximaization and calculate the radius by the
        % neighbors
        if isempty(singTree)
            singTree(1) = pos;
            continue;
        end
        counted = false;
        for key = 1:size(singTree,1)
            if pos == singTree(key,1)
                singTree(key,end+1) = calRad(tree,kk,pos);
                counted = true;
                break;
            end
        end
        if ~counted
            singTree(size(singTree,1)+1,1) = pos;
        end
    end
    % cal junction distance and radius
    count = 1;centroidofSin = [];radiusofSin = [];
    for key = 1:size(singTree,1)
        conn = singTree(key,2:end);
        conn(conn==0) = [];
        if length(conn) >= 2
            centroidofSin(count,:) = tree(singTree(key,1),:);
            radiusofSin(count) = max(conn);   % set the radius by all connected point
            count = count + 1;
        end
    end
    centroids{ii} = centroidofSin;
    radius{ii} = radiusofSin;
end

%% figure
% labels = mod(labels,13);
% figure;imagesc(labels);%colormap('lines');
% hold on;
% for kk = 1:length(centroids)
%     centroid = centroids{kk};
%     radiu = radius{kk};
%     for jj = 1:length(radiu)
%         if radiu(jj) >= 2
%             plot(centroid(jj,2),centroid(jj,1),'r.','MarkerSize',6);
%             plot(centroid(jj,2),centroid(jj,1),'r-square','MarkerSize',radiu(jj)*18,'LineWidth',4);
%         end
%     end
% end

function tree = bfs(Map,idX,idY)
%----breadth first search
global book mv2Nghb m n;
tree = [idX, idY];
book(idX,idY) = 1;
head = 1;tail = 2;
while(head < tail)
    
    for kk = 1:length(mv2Nghb)
        cX = tree(head,1) + mv2Nghb(kk,1);
        cY = tree(head,2) + mv2Nghb(kk,2);
        if cX > m || cX < 1 || cY > n || cY < 1
            continue;
        end
        if Map(cX,cY) ~= 0 && book(cX,cY) ~= 1
            book(cX,cY) = 1;
            tree(tail,:) = [cX, cY];
            tail = tail + 1;
        end
    end
    head = head + 1;
end

function neighMaxLabel(Map,tree,kk)
global mv2Nghb labels m n;
maxVal = Map(tree(kk,1),tree(kk,2));loc = 0;
for ii = 1:length(mv2Nghb)
    location = tree(kk,:) + mv2Nghb(ii,:); % neighbors location
    cX = location(1); cY = location(2);
    if cX > m || cX < 1 || cY > n || cY < 1
        continue;
    end
    if Map(cX,cY) > maxVal
        maxVal = Map(cX,cY);
        loc = ii;
    elseif Map(cX,cY) == maxVal
        loc = [loc; ii];
    end
end
%
switch length(loc)
    case 1
        if loc == 0
            pos = tree(kk,:);
        else
            pos = tree(kk,:) + mv2Nghb(loc,:);
        end
    case 2
        if loc(1) == 0
            % set as edge
            pos = tree(kk,:) + mv2Nghb(loc(2),:);
        else
            % set as center
            pos = tree(kk,:) + round(mean(mv2Nghb(loc,:)));
        end
    otherwise
        if loc(1) == 0
            pos = tree(kk,:) + round(mean(mv2Nghb(loc(2:end),:)));
        else
            % set as multi vote result
            vote = [];label = [];
            for jj = 1:length(loc)
                pos = tree(kk,:) + mv2Nghb(loc(jj),:);
                cLabel = labels(pos(1),pos(2));
                if any(label == cLabel)
                    vote(label == cLabel) = vote(label == cLabel) + 1;
                else
                    label = [label cLabel];
                    vote = [vote 1];
                end
            end
            maxV = label(vote == max(vote));
            labels(tree(kk,1),tree(kk,2)) = maxV(1);
            return;
        end
end
labels(tree(kk,1),tree(kk,2)) = labels(pos(1),pos(2));

function radius = calRad(tree,kk,parent)
% Euclidean distance
radius = sqrt(sum((tree(kk,:)-tree(parent,:)).^2));
