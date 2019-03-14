function alpha = eighthAngle(direc)

assert(any(size(direc) == 2));

if size(direc, 2) ~= 2
    direc = direc';
end

alpha = mod(floor((angle(direc * [1; 1i]) / pi + 1) * 4), 8) + 1;

%% figure

% [xx, yy] = meshgrid(linspace(-1, 1, 100), linspace(-1, 1, 100));
% an = eighthAngle([xx(:), yy(:)]);
% an = reshape(an, 100, 100);
% figure; imagesc(xx(1,:), yy(:,1)', an);