function [pixel_list, img] = RBBx2map(rbbx)
global m n;

if isfield(rbbx, 'rbbx')
    endp = rbbx.rbbx(1,:);
    l = rbbx.l;
    w = rbbx.w;
    direc = rbbx.o;
    direc_v = rbbx.o_v;
else
    endp = rbbx(1,:);
    edges = diff(rbbx);
    lr = pointDist(edges(1:2, :));
    l = lr(1); w = lr(2);
    direc = edges(1,:) / l;
    direc_v = edges(2,:) / w;
end

[imfieldy , imfieldx] = meshgrid(1:.5:ceil(l), 1:0.5:ceil(w));
points = imfieldy(:) * direc + imfieldx(:) * direc_v;
points = bsxfun(@plus, points, endp);
points = round(points);
valid_points =  (points(:,1) > 0 & points(:,1) <= n) & (points(:,2) > 0 & points(:,2) <= m);
points = points(valid_points, :);
pixel_list = sub2ind([m, n], points(:, 2), points(:,1));
pixel_list =unique(pixel_list);

img = false(m, n);
img(pixel_list) = true;
% figure; imshow(img); hold on;
% showRBBx(rbbx);