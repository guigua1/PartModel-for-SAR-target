function target = initialTarget(part)

% initial target with single part
target.rbbx = part.rbbx;
target.l = part.l + part.w;
target.w = part.w;
target.o = part.direc;
target.o_v = part.direc_v;
target.perimeter = part.l;
target.ds = 0;      %inverse density
target.cp =  target.perimeter / target.l / target.w; %inverse compactness