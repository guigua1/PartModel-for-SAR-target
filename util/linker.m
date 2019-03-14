function lincker(poi, ii, type)
switch type
    case 'p'
        pointLink(poi, ii)
    case 'e'
        edgeLink(poi, ii)
    case 's'
        surfaceLink(poi, ii)
end

function surfaceLink(label, sepImg)
global interestTars len;
thrsh = 0.5;
[m,n] = size(sepImg);
mapRegion = zeros(m,n);
tarLoc = interestTars(label).loc;
for ii = 1:size(tarLoc,1)
    mapRegion(tarLoc(ii,1):tarLoc(ii,2),tarLoc(ii,3):tarLoc(ii,4)) = true;
end
tarMean = mean2(sepImg(mapRegion>0));
tarVar = std2(sepImg(mapRegion>0));
for ii = 1:len
    if  (interestTars(ii).book == ii) && (ii ~= label) %&& (interestTars(ii).cata ~= 3)
        tmpLoc = interesTars(ii).loc;tempMean = interesTars(ii).Rmean; tempVar = interesTars(ii).Rvar;
        for jj = 1:size(tmpLoc,1);
            [xx,~] = find(mapRegion(tmpLoc(jj,1):tmpLoc(jj,2),tmpLoc(jj,3):tmpLoc(jj,4)));
            if ~isempty(xx)
                if abs(tempMean(jj)-tarMean)*abs(tempVar(jj)^2 - tarVar^2) < thrsh
                    interestTars(ii).book = label;
                    interestTars(ii).cata = 3;
                    break;
                end
            end
        end
    end
end


function structureLink(label, sepImg)
global searchSpace;
cur = searchSpace(label);
startP = cur.centroid(1,:); endP = cur.centroid(end,:);
distance = sqrt(sum((startP-endP).^2)); [m, n] = size(sepImg);
result = [];
while length(result) < 5 && iterNum < 4
    for ii = max(1,floor(startP(1)-distance)): min(m, floor(startP(1)+distance))
        for jj = max(1,floor(startP(2)-distance)): min(n, floor(startP(2)+distance))
            if (sepImg(ii,jj) ~= 0) && (sqrt(sum(([ii jj]-startP).^2)) < distance)
                if sepImg(ii,jj) ~= label && searchSpace(sepImg(ii,jj)).linkLbl ~= cur.linkLbl
                    result = [result sepImg(ii,jj)];
                end
            end
        end
    end
    distance = 1.5 * distance;
    iterNum = iterNum + 1;
end

while ~isempty(result)
    if length(searchSpace(result(1))) > 1
        temp = searchSpace(result(1));
        direc = temp.centroid(1,:) - temp.centroid(end,:);
        direc1 = octalQuadrant(direc);
        direc2 = octalQuadrant(-direc);
        if (octalQuadrant(startP-endP) == direc1) || (octalQuadrant(startP-endP) == direc2)
            
        end
    end
end


function pointLink(label, sepImg)
% global interestTars len;

