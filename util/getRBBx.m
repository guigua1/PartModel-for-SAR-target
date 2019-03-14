function rbbx = getRBBx(ul_corner, direc, direc_v, len, wid)

rbbx = bsxfun(@plus, ul_corner, [0, 0; len*direc;  len*direc + wid*direc_v; + wid*direc_v; 0, 0]);