
colors = ['y.'; 'b.'; 'r.'; 'g.'];
figure;imshow(ImgMap1, [0 max(max(ImgMap1))]);
hold on;
for kk = 1:length(centroids)
    centroid = centroids{kk};
    radiu = radius{kk};
    for jj = 1:length(radiu)
        if radiu(jj) >= 2
            plot(centroid(jj,2),centroid(jj,1),'r.','MarkerSize',radiu(jj)*12);
            plot(centroid(jj,2),centroid(jj,1),'r-square','MarkerSize',radiu(jj)*12);
        end
    end
%     tree = trees{kk};
%     plot(tree(:,2),tree(:,1),colors(mod(kk,length(colors))+1,:));
end
%%
set(gca,'Position',[0 0 1 1]);
axis normal;
% axis([300 416 128 240]);
% set(gcf,'Position',[0 0 116*4 112*4]);
set(gcf,'Position',[440 440 200 200]);

axis([187 207 126 146]);
axis([196 216 165 185]);
axis([202 222 202 222]);
axis([210 230 240 260]);
axis([218 238 280 300]-1);
axis([228 248 320 340]-3);
axis([384 404 286 306]);

axis([72 92 121 141]);
axis([275 291 222 238]);
axis([300 316 396 412]);
axis([199 215 372 388]);
axis([218 238 280 300]-1);
axis([228 248 320 340]-3);
axis([384 404 286 306]);

imhist(imgFil(:));
hold on;
plot([sepReg(idxClip-1:end,2)'; sepReg(idxClip-1:end,2)'], [zeros(1,size(sepReg,1)-idxClip+2); max(raw_hist)*ones(1,size(sepReg,1)-idxClip+2)],'-black','LineWidth',3)