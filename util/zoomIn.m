function [rangeX, rangeY] = zoomIn(bbx, muted)

if nargin < 2
    muted = false;
end

global m n;

rangeY = max(floor(bbx(1)),1):min(ceil(bbx(1)+bbx(3)), n);
rangeX = max(floor(bbx(2)),1):min(ceil(bbx(2)+bbx(4)), m);

%% in figure

global infigure;
if infigure && muted
    try
        axis([rangeY(1) rangeY(end) rangeX(1) rangeX(end)]);
    catch
        disp('what');
    end
end