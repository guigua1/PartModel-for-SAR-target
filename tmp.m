hold on;
for ii = 1:70
    showRBBx(parts(ii))
    text(parts(ii).rbbx(1,1), parts(ii).rbbx(1,2), num2str(ii), 'Color', 'r');
end