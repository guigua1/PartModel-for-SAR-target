function new_rect = R2BBx(rect, mode)

if nargin < 2
    mode = 'n';
end

switch mode
    case 'n'
        new_rect(1:2) = [min(rect(:,1)), min(rect(:,2))];
        rd = [max(rect(:,1)), max(rect(:,2))];
        new_rect(3:4) = rd - new_rect(1:2);
    case 'r'
        new_rect = getRBBx(rect(1:2), [1 0], [0 1], rect(3), rect(4));
end