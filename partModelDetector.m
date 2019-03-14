function [nms_tar] = partModelDetector(img)

addpath('util'); close all; clc;

%% some parameters
global T_p iou m n save name xpt;

[m, n] = size(img);

%% pre-processing img
% I_t - compressed image; I_e - canny edge
[I_t, I_e] = preImg(img);  % actually histogram equalization might work, too.

% pause();

%% find node of interest
global labels;
labels = zeros(m,n);
iNodes = findINode(I_t);
% NoN = length(iNodes); % number of nodes

f1 = figure('Tag', 'nodes');showNodes(zeros(m, n, 3), iNodes);
if save
    name{3} = f1.Tag;
    export_fig(f1, strjoin(name, ''), xpt{:});
end

% pause();

%% extract node feature: 
node_feats = regFeat(img, I_e, iNodes);

%% connect nodes to generate parts : connectivity and similarity

[parts] = genPart(node_feats);

%% combination inference
% search order based on length of parts

iso_ids = [parts.type] == 's';
[~, large_order] = sort([parts.len], 'descend');
p1 = parts(~iso_ids);
p1 = p1(large_order);
parts = [p1, parts(iso_ids)];

if save
    f2 = figure('Tag', 'parts'); showNodes(img, iNodes);
    f3 = findobj('Tag', 'I_t');

    for ii = [1:sum(~iso_ids), sum(~iso_ids)+randperm(sum(iso_ids), min(3, sum(iso_ids)))]
        p = parts(ii);
        bbx = R2BBx(p.rbbx);
        for f = [f1, f2, f3]
            name{3} = [f.Tag, num2str(ii)];
            figure(f.Number);
            zoomIn(bbx, true);
            export_fig(f, strjoin(name, ''), xpt{:});
            pause(0.5);
        end
    end
end

figure(); imshow(img);
targets = combinePart(parts);

if save
    name{3} = 'comb';
    axis image;
    export_fig(gcf, strjoin(name, ''), xpt{:});
end

c = {'Faces', 1:5, 'FaceColor', 'none', 'EdgeColor', 'g', 'LineWidth', 1.5};

clf; imshow(img);
if save
    for ii = 1:length(targets)
        p = targets(ii);
        showRBBx(p.rbbx, c);
        bbx = R2BBx(p.rbbx);
        name{3} = ['tar', num2str(ii)];
        zoomIn(bbx, true);
        export_fig(gcf, strjoin(name, ''), xpt{:});
        pause(0.5);
    end
end

%% censor targets and NMS
NoT = length(targets);
one_part_tar = false(1,NoT);
for ii = 1:NoT
    if length(targets(ii).p) < T_p
        one_part_tar(ii) = true;
    end
end

[remained_tar, targets] = censor(targets, one_part_tar);
remained_tar = targets(remained_tar);
[nms_tar, tar_labels] = NMS(remained_tar, iou);

clf; imshow(tar_labels); 

if save
    name{3} = 'bw';
    export_fig(gcf, strjoin(name, ''), xpt{:});
end

img(tar_labels == 0) = img(tar_labels == 0) / 4;

figure(); imshow(img); set(gcf, 'Color', 'w');

for ii = 1:length(nms_tar);
    p = nms_tar(ii);
    bbx = R2BBx(p.rbbx);
    zoomIn(bbx, true);
    showRBBx(p.rbbx, c);
    if save
        name{3} = ['nms', num2str(ii)];
        export_fig(gcf, strjoin(name, ''), xpt{:});
        pause(0.5);
    end
end

axis image;
name{3} = 'psd';
export_fig(gcf, strjoin(name, ''), xpt{:});
