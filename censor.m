function [r_tars, tars] = censor(tars, cond)

global T_a;
cond_tar = tars(cond);
mu_len = [cond_tar.l]; mu_wid = [cond_tar.w];
mu_area = mean(mu_len .* mu_wid);
% mu_len = mean(mu_len); mu_wid = mean(mu_wid);
% mu_area2 = mu_len * mu_wid;

r_tars = false(length(tars),1);
for ii = 1:length(tars)
    tars(ii).area = tars(ii).l * tars(ii).w;
    if  ~cond(ii) && tars(ii).area > mu_area * T_a
        r_tars(ii) = true;
%         showRBBx(tars(ii));
    end
end