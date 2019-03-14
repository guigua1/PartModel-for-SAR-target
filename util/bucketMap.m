function sepImg = bucketMap(pixelValue, bucket)
indexNum = length(bucket);
sepImg = pixelValue;
for ii = 1:indexNum-1
    sepImg(pixelValue > bucket(ii)) = ii-1;
end
