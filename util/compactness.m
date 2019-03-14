function [comp, tar] = compactness(tar, parts, save)

if nargin < 3
    save = false;
end

comp = zeros(1,length(parts));

for ii = 1:length(parts)
    part = parts(ii);
    srcP = tar.rbbx(1,:);
    [~, w] = project2D(tar.o_v, part.endp, srcP);
    [~, l] = project2D(tar.o, part.endp, srcP);
    
    if part.type == 's'
        w_ext = [w, w];
        l_ext = [l, l];        
    else        
        % width
        w_ext = minmax(w');
        % length
        l_ext = minmax(l');
    end
    
    w_ext = [min(w_ext(1)-part.w/2, 0), max(w_ext(2)+part.w/2, tar.w)];
    %     w_ext = [min(w_ext(1), -tar.w), max(w_ext(2), 0)];
    l_ext = [min(l_ext(1)-part.w/2, 0), max(l_ext(2)+part.w/2, tar.l)];
    %     l_ext = [min(l_ext(1), 0), max(l_ext(2), tar.l)];
    
    new_w = sum(abs(w_ext));
    new_l = sum(abs(l_ext));

    comp(ii) = (tar.perimeter + part.l) / new_w;
end

if save
    assert(length(parts) == 1)
    tar.cp = comp;
    tar.perimeter = tar.perimeter + part.l - part.w;
    if parts.type == 'p'
        new_o = (tar.o * tar.l + part.direc * part.l * 0.1);
    else
        new_o = (tar.o * tar.l + tar.o_v * w * 0.1);
    end
    new_o = new_o / norm(new_o) * sign(new_o(1));
    new_o_v = [-new_o(2), new_o(1)];
    tar.rbbx = getRBBx(srcP + w_ext(1) * tar.o_v + l_ext(1) * tar.o, new_o, new_o_v, new_l, new_w);
    tar.l = new_l;
    tar.w = new_w;
    tar.o = new_o;
    tar.o_v = new_o_v;
end