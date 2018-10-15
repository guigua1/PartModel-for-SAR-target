function target = initialTarget(part)

target.p = part;
if part.t == 'l'
    target.c_axis = part;
    target.c = mean(part.ep);
else
    target.c_axis = [];
    target.c = part.ep;
end

target.len = part.len;
target.wid = part.r*2;
target.dens = 0;
target.comp = part.len * part.r * 2 / (part.len + 2* part.r);