function [rs_objs, label_map] = NMS(objs, th)

global m n;

rs_objs = 1:length(objs);
label_map = zeros(m, n);

cur = 1;
while cur <= length(objs)
%     imagesc(label_map);
%     if cur == 3
%         disp(cur);
%     end

    if ~ismember(cur, rs_objs)
        cur = cur + 1;
        continue;
    end
    
    if isfield(objs(cur), 'pixel_list') && ~isempty(objs(cur).pixel_list)
        pixel_list = objs(cur).pixel_list;
    else
        pixel_list = RBBx2map(objs(cur).rbbx);
        objs(cur).pixel_list = pixel_list;
    end
    
    query_map = label_map(pixel_list);
    lbls = unique(query_map);
    
    lbls = setdiff(lbls, 0);
    
    if isempty(lbls)
        label_map(pixel_list) = cur;
        imagesc(label_map);
        changed = false;
    else
        lbls = setdiff(lbls, cur);
        if isempty(lbls)
            if changed
                label_map(pixel_list) = cur;
                changed = false;
            end
        else   
            changed = false;
            areas = [objs(lbls).area];
            [~, ids] = sort(areas, 'descend');

            for jj = ids
                overlapped = find(query_map == lbls(jj));
                inner_area = length(overlapped);

                if areas(jj) > length(pixel_list)
                    small_t = cur;
                    iou = inner_area / length(pixel_list);
                else
                    small_t = lbls(jj);
                    iou = inner_area / areas(jj);
                end
                if iou > th
                    if small_t == cur
                        cur = lbls(jj);
                    end
    %                 showRBBx(objs(small_t)); showRBBx(objs(cur));
                    objs(cur) = mergeTarget(objs(cur), objs(small_t));
    %                 showRBBx(objs(cur));
                    objs(cur).pixel_list = [];
                    label_map(label_map == lbls(jj)) = 0;
                    rs_objs = setdiff(rs_objs, small_t);
                    changed = true;
                end
            end
        end
    end
    if ~changed
        label_map(pixel_list) = cur;
        cur = cur + 1;
    end
end

rs_objs = objs(rs_objs);

function t1 = mergeTarget(t1, t2)

t1.p = unique(union(t1.p, t2.p));
t2.endp(1,:) = t2.rbbx(1,:) + t2.w / 2 * (t2.o + t2.o_v); 
t2.endp(2,:) = t2.rbbx(1,:) + (t2.l  - t2.w / 2) * t2.o + t2.w/2 * t2.o_v; 
t2.direc = t2.o; t2.direc_v = t2.o_v; t2.type = 'p';
[~, t1] = compactness(t1, t2, true);