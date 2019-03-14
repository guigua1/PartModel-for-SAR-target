function [p_points, l] = project2D(direc, points, srcP, muted)

if nargin < 4
    muted = true;
end

if nargin < 3
    srcP = [0, 0];
end

vec2p = bsxfun(@minus, points, srcP);
l =  vec2p * direc';
p_points = bsxfun(@plus, l * direc, srcP);
%% figure
global infigure
if infigure && ~muted
%     zoomIn([srcP(2), srcP(1), max(l), max(l)]);
    figure(gcf); hold on;
    plot(points(:,1), points(:,2), '-', 'LineWidth', 2);
    plot([points(:,1), p_points(:,1)]', [points(:,2), p_points(:,2)]', '--yo', 'LineWidth', 2);
%     legend({'原始位置', '投影位置'});
end