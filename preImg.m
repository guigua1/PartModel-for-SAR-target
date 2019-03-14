function [I_t, I_e] = preImg(Img)
global pfa;
% Img = imfilter(Img,ones(2,2)/4,'same');

LEVELS = 32;
h = hist(Img(:), LEVELS); 
h = h/sum(h);
%% seperate the region of intensity value for mapping
sepPoint =[0, cumsum(h)];

interval = diff(sepPoint);

%   -----can be replaced by while loop, and to make sure  interval right

head = length(interval);
while head > 1
    if interval(head) < 1/16/LEVELS
        interval(head-1) = interval(head-1) + interval(head);
        sepPoint(head) = [];
        interval(head) = [];
        head = head - 1;
    else
        head = head - 1;
    end
end
    
% sepPoint(interval < 1/4/LEVELS) = [];

%% bucket map
sepImg = bucketMap(Img, sepPoint);


idxClip= find(sepPoint < 1 -  pfa, 1, 'last');      

I_t = max(0,sepImg - idxClip);
% bw1 = im2bw(I_t);
% bw1 = imclose(bw1, strel('disk', 2));
% I_e = bwperim(bw1);
I_e = edge(I_t,'canny');

%% figure
global infigure save name xpt;
if infigure
    f = figure('Tag', 'histo');
    area(linspace(0,1,LEVELS), h, 'FaceColor', [0.4, 0.4, 0.4]);
    hold on;

    x = sepPoint(idxClip:end);
    plot(repmat(x, 2, 1), [zeros(1,length(x)); max(h)*ones(1,length(x))],'-k','LineWidth',3)
    hold off;
    axis tight; 
    xlabel('Ç¿¶È', 'FontSize', 14); ylabel('ÆµÂÊ', 'FontSize', 14);

    if save
        name{3} = f.Tag;
        export_fig(f, strjoin(name, ''), xpt{:});
    end    
    
    figure('Tag', 'I_t');
    im2show = I_t / max(I_t(:)) * 4 * 255;
    im2show = cat(3, im2show + double(I_e) * 127, im2show, im2show);
    imshow(uint8(im2show));
end