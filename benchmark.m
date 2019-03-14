declare_globals();
global T_c T_s T_a T_p beta iou pfa; global name  save;
%% sandia national laboratory Ku-band image 1
% src = 'img/snl1.png';
% [~, name{2}, ~] = fileparts(src); name{2}(end+1) = '-'; 
% 
% declare_globals();
% pfa = 0.7;
% img = loadData(src);
% [tars] = partModelDetector(img);

%% sandia national laboratory Ku-band image 3
% src = 'img/snl3.png';
% [~, name{2}, ~] = fileparts(src); name{2}(end+1) = '-'; 
% 
% declare_globals();
% beta = 0.1;
% pfa = 0.8;
% img = loadData(src);
% [tars] = partModelDetector(img);

%% sandia national laboratory Ku-band image 2
src = 'img/snl2.png';
[~, name{2}, ~] = fileparts(src); name{2}(end+1) = '-'; 

declare_globals();
img = loadData(src);
[tars] = partModelDetector(img);

%% terraSAR-X ship
src = 'img/boat1.png';
[~, name{2}, ~] = fileparts(src); name{2}(end+1) = '-'; 

declare_globals();
img = loadData(src);
[tars] = partModelDetector(img);

%% SSDD (SAR Ship Detection Dataset)
src = 'img/000011.jpg';
[~, name{2}, ~] = fileparts(src); name{2}(end+1) = '-'; 

declare_globals();
for beta = [0.2, 0.3, 0.4, 0.5, 5]
    img = loadData(src);
    [tars] = partModelDetector(img);
    figure(gcf); text(size(img,1)/2 - 10, size(img,2)/2 + 100,...
        ['\beta = ', num2str(beta)], 'FontSize', 36, 'Color', 'w');
    if save
        name{3} = ['beta', num2str(beta)];
        export_fig(gcf, strjoin(name, ''), '-transparent', '-r300', '-nocrop');
    end
    pause(0.5);
end

%%  x five tanks
src = 'img/tank1.png';
[~, name{2}, ~] = fileparts(src); name{2}(end+1) = '-'; 

declare_globals();
T_c = 8/pi;
beta = 0.5; %
pfa = 0.6;
img = loadData(src);
[tars] = partModelDetector(img);

%% x dongbei
src = 'img/x1.png';
[~, name{2}, ~] = fileparts(src); name{2}(end+1) = '-'; 

declare_globals();
beta = 0.01; %
pfa = 0.8;
img = loadData(src);
[tars] = partModelDetector(img);

%% mstar 1
src = 'img/mstar1.png';
[~, name{2}, ~] = fileparts(src); name{2}(end+1) = '-'; 

declare_globals();
T_s = 1.5;
beta = 0.1;
T_a = 4;
T_p = 3;

pfa = 0.7;
img = loadData(src);
[tars] = partModelDetector(img);

%% mstar2
src = 'img/mstar2.png';
[~, name{2}, ~] = fileparts(src); name{2}(end+1) = '-'; 

declare_globals();
T_s = 3;
beta = 0.5;
pfa = 0.7;
img = loadData(src);
[tars] = partModelDetector(img);

%% mstar 10
src = 'img/mstar10.jpg';
[~, name{2}, ~] = fileparts(src); name{2}(end+1) = '-'; 

declare_globals();
pfa = 0.8;
img = loadData(src);
[tars] = partModelDetector(img);

%% airplane
src = 'img/airplane2.png';
[~, name{2}, ~] = fileparts(src); name{2}(end+1) = '-'; 

declare_globals();
beta = 0.1;
pfa = 0.8;
iou = 0.1;
img = loadData(src);
[tars] = partModelDetector(img);
