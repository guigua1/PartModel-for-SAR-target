function declare_globals()

%% global parameters
global NBR T_c T_s T_a T_p beta iou pfa xpt;
NBR = 8;
T_c = (8/pi)^2;   % threshold for connectivity
T_s = 2;     % threshold for similarity
beta = 0.8; % $ g_ds \times \beta < g_cp $
T_a = 2;
T_p = 2;
iou = 0.3;
pfa = 0.5;

global name infigure save;
infigure = true;
save = false;

% file base name
name{1} = 'fig/x/'; name{3} = '';

% export_fig parameters
xpt = {'-png', '-transparent', '-r150', '-nocrop'};