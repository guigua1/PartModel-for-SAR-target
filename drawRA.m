function pos = drawRA(points,rads)
pos = [];
%h = gcf; figure(h); hold on; %rads = floor(rads);
up = min(points(:,1)-rads'); down = max(points(:,1)+rads');
left = min(points(:,2)-rads'); right = max(points(:,2)+rads');
if down-up > 3 || right-left > 3
    pos = [up, down, left, right];
%     plot([left right right left left],[up up down down up],'r','LineWidth',1);
end
