%% Read wind rose input
wind = wind_input();

%% Read wind turbine input
turbine = turbine_input();

%% Generate wind farm ground structure
Xmin  = -1300; % -/+ 1300 -/+ 3000
Xmax  = +1300;
Xstep = +200;
Ymin  = -1300;
Ymax  = +1300;
Ystep = +200;
thetaStep = 5;

turb_coords = wind_farm_ground_structure('circular', Xmin, Xmax, ...
    Xstep, Ymin, Ymax, Ystep);
% turb_coords = wind_farm_radial_ground_structure(Xstep, Xmax, Xstep,...
%     0, 360-thetaStep, thetaStep);

fig1 = figure();
hold on
sz0 = 25;
scatter(turb_coords.x, turb_coords.y, sz0, 'filled')
title('Wind farm layout ground structure')
xlabel('x [m]')
ylabel('y [m]')
axis equal; drawnow;
set(gca,'FontSize',13)
filename = resFolder + "wind_farm_ground_structure.png";
saveas(gcf, filename,'png')
hold off

%% Precompute losses
xi = 1;
ximin = 1;
xistep = 1; % It is subtructed
xiiter = 10;
losses = calc_losses(turb_coords, wind, turbine, xi);

%% Prepare filters
to = top_opt_functions();
% to = to.loc_vol_filt(turb_coords, turbine.diameter*2); % filter for not correct loc vol constr, but ok if used with diag(x)*H*x - 1 <= 0
to = to.loc_vol_filt_II(turb_coords, turbine.diameter*2); % filter for correct loc vol constraint def

%% Volume constraints settings
num_turbines = length(turb_coords.x);
min_num_turbines = 16; %16 or 64
max_num_turbines = 64; %64 or 256
min_vol_frac = min_num_turbines / num_turbines;
max_vol_frac = max_num_turbines / num_turbines;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code was written by Nicolò Pollini,                                %
% Technion - Israel Institute of Technology                               %
% https://mdo.net.technion.ac.il/                                         %
%                                                                         %
%                                                                         %
% Contact: nicolo@technion.ac.il                                          %
%                                                                         %
% Code repository: https://github.com/pollinico/TopOpt_Wind_Farm          %
%                                                                         %
% Disclaimer:                                                             %
% The author reserves all rights but does not guarantee that the code is  %
% free from errors. Furthermore, the author shall not be liable in any    %
% event caused by the use of the program.                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%