function [ImgMap1, eImg] = preImg(img)

imgFil = imfilter(img,ones(2,2)/4,'same');

% figure;subplot(2,2,1);imshow(img);
raw_hist = hist(imgFil(:),32); 

% seperate the region of intensity value for mapping
sepPoint =[0, floor(cumsum(raw_hist/sum(raw_hist))*255)];
head = 1;
sepReg = [];
for ii=1:length(sepPoint)
    if sepPoint(ii) - sepPoint(head) < 8 % A bad design exist~
        continue;
    end
    sepReg = [sepReg; sepPoint(head)+1 sepPoint(ii)];
    head = ii;
end
sepReg = [sepReg; sepPoint(head) sepPoint(end)];

[m,n] = size(img);
sepImg = zeros(m,n);

% subplot(2,2,2);imshow(imgFil);
% bucket map

[~,idxClip]= max(raw_hist);
idxClip = min(idxClip,length(sepReg));
idxClip = max(bucketMap(idxClip*8,sepReg), ceil(length(sepReg)/3));

sepImg = bucketMap(imgFil, sepReg);

while sum(sepImg(:) > idxClip) < m * n / 32 && idxClip > 3
    idxClip = idxClip - 1;
end

ImgMap1 = max(0,sepImg - idxClip);
bw1 = im2bw(ImgMap1);
% bw1 = imclose(bw1, strel('disk', 1));
% bw1 = bwareafilt(bw1, [0 m*n / 16]);
% ImgMap1 = ImgMap1 .* bw1;
eImg = bwperim(bw1);