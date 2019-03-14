function targets = combinePart(parts)

global labels beta save;

lbl2part = cell(max(labels(:)), 1);

for ii = 1:length(parts)
    for jj = parts(ii).nodes
        lbl2part{jj} = [lbl2part{jj}, ii];
    end
end

labels(labels > length(lbl2part)) = 0;

count = 1;
searched = []; dist_p = -1 * ones(length(parts));
for ii = 1:length(parts)
%     disp(ii);
    if ismember(ii, searched)
        continue;
    end

    p = parts(ii);
    if p.type == 's'
        continue;
    end
    cur_tar = initialTarget(p);
    cur_tar.p = ii;
    showRBBx(cur_tar);
    searched = [searched, ii];
    
    scale = 1;
    skipped_part = 0;
    while scale < 5
        
        search_bbx = [mean(p.endp, 1) - scale / 2 * cur_tar.l, scale*cur_tar.l, scale*cur_tar.l];
%         search_rbbx = R2BBx(search_bbx, 'r');
%         showRBBx(search_rbbx, {'Faces', 1:5,'FaceColor', 'none', 'Edgecolor', [0.5 0 0], 'LineWidth', 2});
%         scanline = [search_rbbx(1,:); mean(p.endp, 1); [0.8, 0.2] * search_rbbx(1:2, :)];
%         
%         cdata = [ 1 0.8 0]' * [1 0  0];
%         c = {'Faces', [1 2 3], 'FaceColor','interp',...
%                 'FaceVertexCData',cdata,...
%                 'EdgeColor', 'none'};
%         showRBBx(scanline, c);
        
        [search_rangeX, search_rangeY] = zoomIn(search_bbx, save);
        nbrs = labels(search_rangeX, search_rangeY);
        nbrs = setdiff(unique(nbrs(:)), 0);
        nbrs = setdiff(unique([lbl2part{nbrs}]), searched);
        nbrs = setdiff(nbrs, skipped_part);
        
        terminated = false;
        
        while ~terminated && ~isempty(nbrs)
            terminated = true;
            search_ps = parts(nbrs);
            
            % compactness
            comp = compactness(cur_tar, search_ps);
            [comp, ids] = sort(comp, 'descend');
            nbrs = nbrs(ids);
            
            % density
            for jj = 1:length(comp)
                dense = 0;
                nbr_part = nbrs(jj);
                for cur_part = cur_tar.p
                    if dist_p(nbr_part, cur_part) == -1
                        dist_p(nbr_part, cur_part) = partDist(parts(nbr_part), parts(cur_part));
                        dist_p(cur_part, nbr_part) = dist_p(nbr_part, cur_part);
                    end
                    dense = dense + dist_p(nbr_part, cur_part) * parts(cur_part).l;
                end
                dense = dense / length(cur_tar.p) / cur_tar.l;
               
                if dense * beta < comp(jj)
                    [~, cur_tar] = compactness(cur_tar, parts(nbr_part), true);
                    cur_tar.p = [cur_tar.p, nbr_part];
                    cur_tar.ds = cur_tar.ds + dense;

                    showRBBx(parts(nbr_part));
                    
                    searched = [searched, nbr_part];
                    nbrs(jj) = [];
                    terminated = false;
                    break;
                end
            end
        end
        skipped_part = union(skipped_part, nbrs);
        scale = scale + 1;
    end
    targets(count) = cur_tar;
    count = count + 1;
end