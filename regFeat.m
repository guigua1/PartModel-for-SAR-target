function feats = regFeat(Img, I_e, iNodes)
% encoding the region whose centroid and radius is given
% as input arg (centroids, radius)

global labels m n save;

NoR = length(iNodes);

% initialize features
feats(NoR).center = [];

%% shape and value features
% centers
[cetM, cetN] = ind2sub([m, n], [iNodes.lbl]);
% bounding box
bbx = regionprops(labels, 'BoundingBox');
for ii = 1:NoR
    feats(ii).center = [cetN(ii), cetM(ii)];
    feats(ii).bbx = bbx(ii).BoundingBox;
    feats(ii).radius = max(feats(ii).bbx(3:4)) / 2;
    
    % mean and standard variance
    img_r = Img([iNodes(ii).pixel_list; iNodes(ii).lbl]);
    feats(ii).mu = mean(img_r);
    feats(ii).sigma = std(img_r);
    
    % edge - \rho
    
    [local_m, local_n] = zoomIn(feats(ii).bbx, save);
    
    feats(ii).nbrs = setdiff(unique(labels(local_m, local_n)), [ii, 0]);
    
    edge_pixels = I_e(local_m, local_n);
    [edge_m, edge_n] = find(edge_pixels);
    
    feats(ii).a_mom = zeros(8,1);
    if isempty(edge_m)
        continue;
    end
    
    o_m = find(local_m == cetM(ii));
    o_n = find(local_n == cetN(ii));
        
    edge_v = bsxfun(@minus, [o_m, o_n], [edge_m, edge_n]);
    edge_dist = pointDist(edge_v);
    edge_v = bsxfun(@rdivide, edge_v, edge_dist);
    edge_angle = eighthAngle(edge_v);
    
    for jj = unique(edge_angle')
        % edge orientation and dist
        e_j = edge_dist(edge_angle == jj);
        if isempty(e_j)
            continue;
        end
        feats(ii).a_mom(jj) = length(e_j) / mean(e_j + eps);
    end
end