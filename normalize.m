function img = normalize(Img1, dim)
if nargin <2
    dim = 2;
end
[m,n,l]= size(Img1);
img = zeros(m,n,l);
for ii = 1:l
    Img2 = Img1(:,:,ii);
    if dim == 2
        img(:,:,ii) = floor(255*(Img1-min(Img2(:)))/(max(Img1(:))-min(Img2(:))));
    else
        img(:,:,ii) = floor(255*(Img2-repmat(min(Img2),size(Img2,1),1))...
                        ./repmat(max(Img2)-min(Img2),size(Img2,1),1));
    end
end