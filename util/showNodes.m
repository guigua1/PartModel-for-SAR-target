function [img] = showNodes(bgd, Nodes)

%% figure
global m n;

if size(bgd, 3) == 1
    bgd = repmat(bgd, 1, 1, 3);
end
bgd = reshape(bgd, [], 3);
for ii = 1:length(Nodes)
    bgd(Nodes(ii).lbl, :) = [255 255 255];
    bgd(Nodes(ii).pixel_list, :) = bgd(Nodes(ii).pixel_list, :) + (ones(length(Nodes(ii).pixel_list), 1) * randi(127, 1, 3));
end
img = uint8(reshape(bgd, m, n, []));
imshow(img);