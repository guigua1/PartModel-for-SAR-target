function d = partDist(p2, p1)

if p1.type == 's' && p2.type == 's'
    d = norm(p1.endp - p2.endp);
elseif p1.type == 's'
    [~, l] = project2D(p2.direc, p1.endp, p2.endp(1,:));
    if l < 0
        d = pointDist(p1.endp, p2.endp(1,:));
    elseif l < p2.l
        d = pointDist(p1.endp, p2.endp(2,:));
    else
        [~, d] = project2D(p2.direc_v, p1.endp, p2.endp(1,:));
        d = abs(d);
    end
elseif p2.type == 's'
    [~, l] = project2D(p1.direc, p2.endp, p1.endp(1,:));
    if l < 0
        d = pointDist(p2.endp, p1.endp(1,:));
    elseif l < p1.l
        d = pointDist(p2.endp, p1.endp(2,:));
    else
        [~, d] = project2D(p1.direc_v, p2.endp, p1.endp(1,:));
        d = abs(d);
    end
else
    alpha = acos(p2.direc * p1.direc');
    [~, h] = project2D(p1.direc_v, p2.endp, p1.endp(1,:));
    [~, l] = project2D(p1.direc, p2.endp, p1.endp(1,:));
    if alpha < 10^(-1) 
        if max(l) < 0
            d = sqrt(min(h)^2 + max(l)^2);
        elseif min(l) > p1.l
            d = sqrt(min(h)^2 + (min(l) - p1.l)^2);            
        else
            d = min(abs(h));
        end
    else
        cross_point = l(1) - h(1) / tan(alpha);
        vp_12 = cross_point * sin(alpha)^2;
        if cross_point < 0
            if min(l)< vp_12 && max(l) >= vp_12
                d = abs(-cross_point * sin(alpha));
            elseif max(l) < vp_12
                query = find(l == max(l));
                d = sqrt(max(l)^2 + h(query(1))^2);
            elseif min(l) < 0
                d = sqrt(min(abs(h))^2 + min(l)^2);
            elseif min(l) < p1.l
                d = min(abs(h));
            else
                d = sqrt(min(abs(h))^2 + (min(l) - p1.l)^2);
            end
        elseif cross_point < p1.l
            if min(l) <= cross_point && max(l) >= cross_point
                d = 0;
            elseif min(l) > p1.l
                d = sqrt(min(abs(h))^2 + (min(l) - p1.l)^2);
            elseif min(l) > cross_point || max(l) >= 0
                d = min(abs(h));
            else
                d = sqrt(max(l)^2 + min(abs(h))^2);
            end
        else
            if min(l) > (cross_point - p1.l) * cos(alpha)^2
                query = find(l == min(l));
                d = sqrt((min(l) - p1.l)^2 + h(query(1))^2);
            elseif max(l) > (cross_point - p1.l) * cos(alpha)^2
                d = abs((cross_point - p1.l) * sin(alpha));
            elseif max(l) > p1.l
                d = sqrt(min(abs(h))^2 + (max(l) - p1.l).^2);
            elseif max(l) >= 0
                d = min(abs(h));
            else
                d = sqrt(min(abs(h))^2 + max(l)^2);
            end
        end
    end
end

if d<0
    d= 0;
end
    