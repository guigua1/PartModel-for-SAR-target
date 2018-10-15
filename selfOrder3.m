function [parts, newParts] = selfOrder3(tar)

tempParts = bfsInsert(tar.centroids); parts = []; newParts = [];

centroids = tar.centroids; radius = tar.radius;
% disp(parts);
% draw boxs for centroids
h = gcf;figure(h); hold on;

if length(tempParts) == 1
    return;
end

for jj = 1:length(tempParts)
    pos = drawRA(centroids(tempParts{jj},:), radius(tempParts{jj}));
    if ~isempty(pos)
        temp.centroids = centroids(tempParts{jj},:);
        temp.pos = pos;
        temp.cod = tar.cod(tempParts{jj},:);
        parts = [parts {temp}];
    end
end

conn = [];

for ii = 1:length(parts)
    for jj = ii+1:length(parts)
        if isInclud(parts{ii}.pos,parts{jj}.pos)
            conn = minConn(parts{ii}, parts{jj});
        end
        if ~isempty(conn)
            newParts = insertConn(newParts, ii, jj, conn);
        end
    end
end

%% clear up parts
book = zeros(1,length(parts));
for ii = 1:length(newParts)
    conn = newParts{ii}.conn;
    for jj = 1:size(conn,1)
        book(conn(jj,1)) = 1;
        
    end
end

if (length(newParts) + length(parts)) < 9  || (length(newParts) + length(parts))> 15
    return;
end

%% figure
% h = gcf;figure(h); hold on;
% for ii = 1:length(parts)
%     if book(ii)
%         pos = parts{ii}.pos; up = pos(1); down = pos(2); left = pos(3); right = pos(4);
%         plot([left right right left left],[up up down down up],'w','LineWidth',1);
%     end
% end
% for ii = 1:length(newParts)
%     conn = newParts{ii}.conn;
%     plot(conn(:,3),conn(:,2),'-','LineWidth',6);
%     plot(conn(:,3),conn(:,2),'o','LineWidth',2,'MarkerSize',2);
% end

function parts = bfsInsert(centroids)
% neighboor parts breadth first search
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

function result = isInclud(pos1,pos2)
%% check the overlap of rectAngle 
h = (pos1(1:2)-pos2([2 1]))>0;
v = (pos1(3:4)-pos2([4 3]))>0;
result = ~h(1) && h(2) && ~v(1) && v(2);
% result = true;

function conn = minConn(rawP, tarP)
%% connect overlapped parts
curDis = inf;conn = []; direc = [];
rawPoints = rawP.centroids; rawEdge = rawP.cod; tarPoints = tarP.centroids; tarEdge = tarP.cod;
for ii = 1:size(rawPoints,1)
    for jj = 1:size(tarPoints,1)
        pointII = rawPoints(ii,:); 
        pointJJ = tarPoints(jj,:);
        vectorPoint =  pointII - pointJJ;
        directionTar = octalQuadrant(-vectorPoint);
        directionRaw = octalQuadrant(vectorPoint);
        edgeII = rawEdge(ii,directionTar); edgeJJ = tarEdge(jj,directionRaw);

        if (~all(edgeII)) || (~all(edgeJJ))
            distance = sqrt(sum(vectorPoint.^2));
            if distance < curDis
                curDis = distance;
%                 if pointII(1) < pointJJ(1)
                    conn = [pointII; pointJJ];
%                 else
%                     conn = [pointJJ; pointII];
%                 end
            end
        end
    end
end

function parts = insertConn(parts, sP, eP, conn)
%% find related connection
if conn(1,1) > conn(2,1) || (conn(1,1) == conn(2,1) && conn(1,2) > conn(2,2))
    conn = conn(end:-1:1,:);
    temp = sP;
    sP = eP;
    eP = temp;
end
direc = octalQuadrant(conn(1,:)-conn(2,:));
for ii = 1:length(parts)
    points = parts{ii}.conn;
    for jj = 1:size(points,1)
        for kk = ii+1:size(points,1)
            if [sP eP] == [points(jj,1) points(kk,1)]
                return;
            end
        end
    end
end


for ii = 1:length(parts)
    if comp(direc,parts{ii}.direc)
        points = parts{ii}.conn;
        for jj = 1:size(points,1)
            if conn(1,1) > points(jj,2) || (conn(1,1) == points(jj,2) && conn(1,2) > points(jj,3))
                continue;
            else
                if conn(1,:) ~= points(jj,2:3)
                    points(jj:end+1,:) = [sP conn(1,:); points(jj:end,:)];
                end
                for kk = jj+1:size(points,1)
                    if conn(2,1) > points(kk,2) || (conn(2,1) == points(kk,2) && conn(2,2) > points(kk,3))
                        continue;
                    end
                    if conn(2,:) ~= points(kk,2:3)
                        points(kk:end+1,:) = [eP conn(2,:); points(kk:end,:)];
                        parts{ii}.conn = points;
                        return;
                    else
                        parts{ii}.conn = points;
                        return;
                    end
                end
                points(end+1,:) = [eP conn(2,:)];
                parts{ii}.conn = points;
                return;
            end
        end
        points(end+(1:2),:) = [sP conn(1,:); eP conn(2,:)];
        parts{ii}.conn = points;
        return;
    end
end
tempC.conn = [sP conn(1,:); eP conn(2,:)];
tempC.direc = direc;
parts = [parts {tempC}];


function result = comp(d1, d2)
%% compare direction of connection
result = ~isempty(intersect(d1, d2));
