function showRBBx(a, c)

if nargin < 2
    c = {'Faces', 1:5, 'FaceColor', 'flat', 'FaceVertexCData', [1 1 1],...
        'EdgeColor', rand(1,3), 'LineWidth', 2};
%     c = {'Faces', 1:5, 'FaceColor', 'none', 'EdgeColor', 'w', 'LineWidth', 1.5};
end

if isfield(a, 'rbbx')
    rbbx = a.rbbx;
else
    rbbx = a;
end

figure(gcf); hold on;
pb = patch('Vertices', rbbx, c{:});
alpha(pb, 0.5);
hold off;