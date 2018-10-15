function sepImg = bucketMap(pixelValue, bucket)
indexNum = length(bucket); sepImg = zeros(size(pixelValue));
for ii = 1:indexNum
    sepImg(pixelValue >= bucket(ii,1)) = ii;
end
