function [adens, acomp] = denseAndCompact(target, part)

ps = target.p;
dens = 0;
for ii = 1:length(ps)
    p = ps(ii);
    if p.t == 'p' || p.t == 's'
        if part.t == 'l'
            ep = p.ep;
            ep_p = project2part(part, ep);
            h_sp = ep_p - part.ep(1,:);
            h_ep = ep_p - part.ep(2,:);
            outer = h_sp * h_ep';
            if outer < 0
                dens = dens + norm(ep - ep_p);
            else
                dens = dens + min(norm(ep - part.ep(1,:)), norm(ep - part.ep(2,:)));
            end
        else
            dens = dens + norm(p.ep - part.ep);
        end
    else
        if part.t == 'l'
            sp = part.ep(1,:);
            ep = part.ep(2,:);
            sp_p = project2part(p, sp);
            ep_p = project2part(p, ep);
            v_sp1 = sp_p - sp;
            v_ep1 = ep_p - ep;
            outer1 = v_sp1 * v_ep1';
            sp = p.ep(1,:);
            ep = p.ep(2,:);
            sp_p = project2part(part, sp);
            ep_p = project2part(part, ep);
            v_sp2 = sp_p - sp;
            v_ep2 = ep_p - ep;
            outer2 = v_sp2 * v_ep2';
            if outer1 <= 0 && outer2 <= 0
                dens = dens + 0;
            else
                dens = dens + min([norm(v_sp1), norm(v_ep1), norm(v_sp2), norm(v_ep2)]');
            end
        else
            ep = part.ep;
            ep_p = project2part(p, ep);
            outer = (ep_p - p.ep(1,:)) * (ep_p - p.ep(2,:))';
            if outer < 0
                dens = dens + norm(ep - ep_p);
            else
                dens = dens + min(norm(ep - p.ep(1,:)), norm(ep - p.ep(2,:)));
            end
        end
    end
end

if isempty(target.c_axis)
    if part.t == 'l'
        cp_p = project2part(part, target.c);
        if norm(cp_p - target.c) < target.len / 2
            comp = (target.len) * part.len / (target.len + part.len);
        else
            new_len = norm(cp_p - target.c) + target.len/2 + part.r;
            comp = new_len*target.wid / (new_len + target.wid);
        end
    else
        new_len = norm(target.c - part.ep) + target.len / 2 + part.r;
        comp = new_len*target.wid/(new_len + target.wid);
    end
else
    if part.t == 'l'
        sp_p = project2part(target.c_axis, part.ep(1,:));
        ep_p = project2part(target.c_axis, part.ep(2,:));
        new_len = max(norm(sp_p - target.c), norm(ep_p - target.c))+part.r;
        v_sp = sp_p - part.ep(1,:);
        v_ep = ep_p - part.ep(2,:);
        outer = v_sp * v_ep';
        if new_len > target.len/2
            if outer <= 0
                new_wid = max(target.wid/2, [norm(v_sp), norm(v_ep)] + part.r);
                comp = (new_len + target.len/2) * sum(new_wid) / (new_len + target.len/2 + sum(new_wid));
            else
                new_wid = max(norm(v_sp), norm(v_ep)) + part.r;
                comp = (new_len + target.len/2) * (new_wid + target.wid /2 ) / (new_len + target.len/2 + new_wid + target.wid/2);
            end
        else
           if outer <= 0
                new_wid = max(target.wid/2, [norm(v_sp), norm(v_ep)] + part.r);
                comp = target.len * sum(new_wid) / (target.len + sum(new_wid));
            else
                new_wid = max(norm(v_sp), norm(v_ep)) + part.r;
                comp = target.len * (new_wid + target.wid /2 ) / (target.len + new_wid + target.wid/2);
           end
        end
    else
        ep_p = project2part(target.c_axis, part.ep);
        new_len = max(target.len/2, norm(ep_p - target.c)+part.r);
        new_wid = max(target.wid/2, norm(ep_p - part.ep)+part.r);
        comp = (new_len + target.len/2) * (new_wid + target.wid/2) / (new_len + target.len/2 + new_wid + target.wid/2);
    end
end

adens = dens/length(ps) - target.dens;
acomp = comp - target.comp;