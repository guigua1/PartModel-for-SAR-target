function flow(src)

%% pre-processing img
img = loadData(src);
% img = histeq(img);
[cImg, eImg] = preImg(img);
[m, n] = size(img);

global S_tol Nbr E_tol;
S_tol = 0.5; Nbr = 4; E_tol = 1.25;

%% find points of interest
[centroids, radius, trees] = findEnd(cImg);
N_Conn = length(trees); 
Conn_Rs = {};
N_PoI = 1; 
for ii = 1:N_Conn
    P_good = find(radius{ii} >= 1.5);
    if isempty(P_good)
        continue;
    end
    conn_r.r = radius{ii}(P_good);
    conn_r.trees = trees{ii};
    conn_r.c = centroids{ii}(P_good,:);
    conn_r.len = length(P_good);
    Conn_Rs{N_PoI} = conn_r;
    N_peak(N_PoI) = conn_r.len;
    N_PoI = N_PoI + 1;
end

%% categorize points of interest 
[lowSplit, highSplit] = sepCata(N_peak);
categ =  catalogByLen(N_peak, lowSplit, highSplit);
conste_star = find(categ == 2);
iso_star = find(categ == 1);

for ii = conste_star
    conn_r = Conn_Rs{ii};
    % extract region feature: connectivity and similarity
    [conn_r.cod, ~, conn_r.loc, conn_r.m, conn_r.v] = regEncode(img, eImg, conn_r.c, conn_r.r);
    % order points in the same connect region into parts
    [conn_r.parts, conn_r.d] = selfOrder(conn_r);
    Conn_Rs{ii} = conn_r;
end

%% squeeze parts and locate search region
partsMap = zeros(m,n); width = 10; 
cur_p = 1;
figure; imshow(cImg, []); hold on;
for ii = conste_star
    stars = Conn_Rs{ii};
    for jj = 1:length(stars.parts)
        
        centroids  = stars.c(stars.parts{jj}, :);
        r = mean(stars.r(stars.parts{jj}));
        partsMap(sub2ind([m, n], centroids(:,1), centroids(:,2))) = cur_p;
        
        if size(centroids,1) > 1
            % use segment to replace original list of PoI
            [yy, cur_i] = sort(centroids(:,2));
            yy = unique(yy);
            if length(yy) == 1
                sp = min(centroids(:,1)); ep = max(centroids(:,1));
                parts(cur_p).bias = yy;
                parts(cur_p).d = [1; 0];
                parts(cur_p).bias =  -yy;
                parts(cur_p).len = ep - sp + 2*r;
                parts(cur_p).ep = [sp, yy; ep, yy];
                xx = centroids(cur_i, 1);
            else
                d = polyfit(centroids(:,2), centroids(:,1), 1);
                xx = polyval(d, yy);
                normd =  sqrt(1+d(1)^2);
                
                parts(cur_p).d = [d(1); 1]/normd;
                parts(cur_p).bias = d(2)/normd;
                parts(cur_p).len = (yy(end) - yy(1))*normd + 2*r;
                
                parts(cur_p).ep = [xx(1), yy(1); xx(end), yy(end)];
            end
            parts(cur_p).t = 'l';
            
            left = min(stars.loc(cur_i([1 end]), 3)) - width;
            right = max(stars.loc(cur_i([1 end]), 4)) + width;
            up =  min(max(1, stars.loc(cur_i([1 end]), 1))) - width;
            down = max(min(n, stars.loc(cur_i([1 end]), 2))) + width;
            loc = [up, down, left, right];
            
        else
            parts(cur_p).len = 2 * r;
            loc = stars.loc(stars.parts{jj},:) + [-1, 1, -1, 1] * width;
            parts(cur_p).t = 'p';
            parts(cur_p).ep = centroids;
        end
        loc = max(1, loc);
        loc(2) = min(m, loc(2));
        loc(4) = min(n, loc(4));
        parts(cur_p).loc = loc;
        parts(cur_p).r = r;
        
        plot(parts(cur_p).ep(:,2), parts(cur_p).ep(:,1), '-o', 'LineWidth', 2);
        rectangle('Position', [loc(3), loc(1), max(1,loc(4)-loc(3)), max(1,loc(2)-loc(1))], 'EdgeColor', 'r');

        cur_p = cur_p + 1;
    end
end

%% search order based on length of parts
N_parts = cur_p - 1;

[~, search_index] = sort([parts.len], 'descend');


% append single point targets
for ii = iso_star
    ipt = Conn_Rs{ii};
    partsMap(ipt.c(1,1), ipt.c(1,2)) = cur_p;
    parts(cur_p).r = ipt.r(1);
    parts(cur_p).t = 's';
    parts(cur_p).ep = ipt.c;
    plot(ipt.c(1,2), ipt.c(1,1), '-o', 'LineWidth', 1);
    cur_p = cur_p + 1;
end
searched = false(1, cur_p-1);

%% combine parts from constellate points
n_target = 0; 
figure(); imshow(cImg,[]); hold on;
for ii = search_index
    if searched(ii)
        continue;
    end
    n_target = n_target + 1;
    targets(n_target) = initialTarget(parts(ii));
    searched(ii) = true;
    search_loc = parts(ii).loc;
    
%     axis(search_loc([3 4 1 2]));
    plot(parts(ii).ep(:,2), parts(ii).ep(:,1), '-o', 'LineWidth', 2);
    
    inner_order = unique(partsMap(search_loc(1):search_loc(2), search_loc(3):search_loc(4)));
    inner_order(inner_order == 0) = [];
    terminated = false;
    while ~terminated
        max_c = 0; terminated = true; new_part = 0; tmp_dens = 0;
        for jj = inner_order'
            if searched(jj)
                continue;
            end
            [dens, comp] = denseAndCompact(targets(n_target), parts(jj));
            if comp <= 0
                % contained parts
                searched(jj) = true;
%                 targets(n_target).p = [targets(n_target).p, parts(jj)];
            else
                if dens*0.8 < comp
                    if comp > max_c
                        max_c = comp;
                        tmp_dens = dens;
                        new_part = jj;
                    end
                end
            end
        end
        if new_part ~= 0
            searched(new_part) = true;
            targets(n_target).p = [targets(n_target).p, parts(new_part)];
            targets(n_target).dens = targets(n_target).dens + tmp_dens;
            targets(n_target).comp = targets(n_target).comp + max_c;
            plot(parts(new_part).ep(:,2), parts(new_part).ep(:,1), '-o', 'LineWidth', 2);
            terminated = false;
        end
    end
end

ms = mean([targets.len])*0.5;
figure(); imshow(img,[]); hold on;
for ii = 1:length(targets)
    target = targets(ii);
    if target.len > ms && length(target.p) > 1
        for jj = 1:length(target.p)
            p = target.p(jj);
            plot(p.ep(:,2), p.ep(:,1),'-o', 'LineWidth', 2);
        end
%     else
%         for jj = 1:length(target.p)
%             p = target.p(jj);
%             plot(p.ep(:,2), p.ep(:,1),'-go', 'LineWidth', 2);
%         end
    end
end

function [lowSplit, highSplit] = sepCata(lens)
    lens = sort(lens); 
    highSplit = length(lens);
    [~,lowSplit] = max(hist(lens,lens(highSplit))); 

    while lens(highSplit-1) < lens(highSplit)/2 || lens(highSplit) < 2 * lowSplit
        highSplit = highSplit -1;
    end

    highSplit = lens(highSplit);


function cata = catalogByLen(len, lowSplit, highSplit)
    cata = ones(size(len));
    cata(len > lowSplit) = 2;
    cata(len > highSplit) = 3;