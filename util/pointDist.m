function d = pointDist(a, b)
% Euclidean distance

assert(~isempty(a), 'no points');

if nargin == 1
    b = [0, 0];
end

assert(size(a, 2) == 2 && size(b,2) == 2, '2D points should have pair-value.');

if size(a, 1) > 1 && size(b, 1) > 1
    xx = bsxfun(@minus, a(:,1), b(:,1)');
    yy = bsxfun(@minus, a(:,2), b(:,2)');
    d = sqrt(xx.^2 + yy.^2);
elseif size(a, 1) == 1 && size(b, 1) == 1
    d =norm(a-b);
else
    d = sqrt(sum(bsxfun(@minus, a, b).^2, 2));
end