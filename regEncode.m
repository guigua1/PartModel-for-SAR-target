function [codRegion, motRegion, loc, Rmean, Rvar] = regEncode(Img, eImg, centroids, radius)
% encoding the region whose centroid and radius is given
% as input arg (centroids, radius)

global E_tol;

len = size(centroids,1); %extSize = 1;
codRegion = zeros(len,8);
motRegion = codRegion;
loc = zeros(len,4);
Rmean = zeros(len,1);
Rvar = zeros(len,1);
[m,n] = size(Img);

for ii = 1:len
    if radius(ii) < 1
        continue;
    end
    width = floor(radius(ii));
    x = centroids(ii,1); y = centroids(ii,2);
    up = max(1, x-width); down = min(m, x+width); lef = max(1, y-width); rig = min(n, y+width);
    loc(ii,:) = [up down lef rig];
    region = Img(up:down, lef:rig);
    eofRegion = eImg(up:down, lef:rig);
%     colormap(gray);figure; imagesc(eofRegion);figure;imagesc(region);
    region = region(region>0);
    [dirX, dirY] = find(eofRegion);
    Rmean(ii) = mean2(region);
    Rvar(ii) = std2(region);
    scales = sqrt(((down-up)/2+1-dirX).^2+((rig-lef)/2+1-dirY).^2);
    directions = [dirX-(down-up)/2-1, dirY-(rig-lef)/2-1];
%     disp(num2str([(down-up)/2,(rig-lef)/2]));
    for jj = 1:size(directions,1)
        direcLoc = octalQuadrant(directions(jj,:));
%         disp(direcLoc);
        codRegion(ii,direcLoc) = codRegion(ii,direcLoc) + 1;
        motRegion(ii,direcLoc) = motRegion(ii,direcLoc) + 1/scales(jj);
    end
    
end

codRegion = codRegion.*motRegion;
codRegion = codRegion > E_tol;