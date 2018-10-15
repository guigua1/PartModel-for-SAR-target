function [parts, newParts] = selfOrder2(tar)
parts = bfsInsert(tar.centroids); newParts = [];
centroids = tar.centroids;radius = tar.radius;
% disp(parts);
% draw boxs for centroids
h = gcf;figure(h); hold on;
for jj = 1:length(parts)
    drawRA(centroids(parts{jj},:), radius(parts{jj}));
end
for ii = 1:length(parts)-1
    rawP = parts{ii};
    for jj = ii+1:length(parts)
        tarP = parts{jj};
        temp = minConn(rawP,tarP, tar);
        if ~isempty(temp)
            extP(ii,jj) = temp;
        end
    end
end
if ~exist('extP', 'var')
    return;
end
for ii = 1:size(extP,1)
    extP = iterFind(ii, extP);
end

newParts = [];

for ii =1:size(extP,1)
    for jj = ii+1:size(extP,2)
        if ~extP(ii,jj).cancel
            tempResult = searchDeep(extP, ii, jj, parts);
%             disp(tempResult);
            newParts = [newParts {tempResult}];
            % draw lines for connections
            h = gcf;figure(h);
            plot(centroids(tempResult,2),centroids(tempResult,1),'-or','LineWidth',1);
            extP(ii,jj).cancel = true;
        end
    end
end

% 
% for ii = 1:length(newParts)
%     % least distance arrangement
%     tempParts = newParts{ii};
%     tempParts = [tempParts(1) tempParts(2:2:end-1) tempParts(end)];
%     if length(tempParts)>2
%         newParts{ii} = sortCentroids(centroids(tempParts,:), tempParts);
%     end
% end

function parts = bfsInsert(centroids)
l = size(centroids,1);thDis = 1.42;curInd = 1;sepInd = 1;
temp = 1:l; parts = [];
while curInd < l
    flag = 0;
    for aft = curInd+1:l
        for pre = sepInd:curInd
            dis = cenDis(centroids(temp(aft),:), centroids(temp(pre),:));
            if dis < thDis
                midTemp = temp(aft);
                temp(pre+2:aft) = temp(pre+1:aft-1);
                temp(pre+1) = midTemp;
                curInd = curInd+1;
                flag = 1;
                break;
            end
        end
    end
    if flag == 0
        parts = [parts {temp(sepInd:curInd)}];
        sepInd = curInd+1;
        curInd = sepInd;
    end
end
parts = [parts {temp(sepInd:curInd)}];

function conn = minConn(rawP, tarP, tar)
curDis = inf; conn.connect = [];conn.dis = 0; conn.direc = [];conn.cancel = true;
for ii = 1:length(rawP)
    for jj = 1:length(tarP)
        pointII = tar.centroids(rawP(ii),:); 
        pointJJ = tar.centroids(tarP(jj),:);
        vectorPoint =  pointII - pointJJ;
        directionTar = octalQuadrant(-vectorPoint);
        directionRaw = octalQuadrant(vectorPoint);
        edgeII = tar.cod(rawP(ii),directionTar); edgeJJ = tar.cod(tarP(jj),directionRaw);

        if (~all(edgeII)) || (~all(edgeJJ))
%             size = abs(tar.radius(rawP(ii)) - tar.radius(tarP(jj)));
            div = abs((tar.Rmean(rawP(ii)) - tar.Rmean(tarP(jj))))*max(tar.Rvar(rawP(ii))/tar.Rvar(tarP(jj)), tar.Rvar(tarP(jj))/tar.Rvar(rawP(ii)));
            if div < 2
                
                distance = sqrt(sum(vectorPoint.^2));
                if distance < curDis
                    curDis = distance;
                    conn.connect = [ii jj];
                    conn.direc = union(directionTar, directionRaw);
                    conn.dis = distance;
                    conn.cancel = false;
                end
            end
        end
    end
end


function extP = iterFind(row, extP)
for ii = row+1:size(extP,1)
    if ~isempty(extP(row, ii).connect)
        for jj = ii+1:size(extP,2)
            if ~extP(row, jj).cancel
                if ~extP(ii,jj).cancel
                    [~,ind] = max([extP(row,ii).dis extP(row,jj).dis extP(ii,jj).dis]);
                    switch ind
                        case 1
                            extP(row,ii).cancel = true;
                        case 2
                            extP(row,jj).cancel = true;
                        case 3
                            extP(ii,jj).cancel = true;
                    end
                end
            end
        end
    end
end

function result= compare(link1, link2)
result = ~isempty(intersect(link1.direc, link2.direc));


function result = searchDeep(extP, ii, jj, parts)

if extP(ii,jj).cancel
    return;
end
tii = parts{ii}; tjj = parts{jj}; 
conn = extP(ii,jj).connect;
result = [tii(conn(1)) tjj(conn(2))];
for mm = jj+1:size(extP,2)
%     disp(size(extP));
    if ~extP(jj, mm).cancel && compare(extP(ii, jj), extP(jj,mm))
        tempResult = searchDeep(extP, jj, mm, parts);
        result = [result tempResult];
    end
end
% 
% function result = sortCentroids(cen,ind)
% % insert sort
% for ii = 3:length(ind)
%     for jj = 1:ii-1
%         if cen(ii,1)<
%             
%         end
%     end
% end
