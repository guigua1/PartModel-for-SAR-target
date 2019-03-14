function img = loadData(str)
if ischar(str)
    if strcmp(str(end-4:end), '.mat')
        strc = load(str);
        img = strc.img;
    else
        img = imread(str);
    end
else
    img = str;
end
img=double(img(:,:,1));
img = normalize(img);

global infigure;
if infigure
    figure('Name', 'Raw Image'); imshow(img, []);
end