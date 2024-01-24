%% Code for wind farm layout topology optimization
%  Nicolò Pollini
%  The code implements the optimization approach proposed in: 
%  Pollini, N. (2022). Topology optimization of wind farm layouts. 
%  Renewable Energy, 195, 1015-1027.

%%
close all
clear variables
clc
commandwindow


resFolder = "./results/";
addpath("lib")

if exist(resFolder+"Log_SLP.txt", 'file') == 2
    diary off
    delete(resFolder+"Log_SLP.txt");
end
diary(resFolder+"Log_SLP.txt") % Save commandwindow output to file


%% Set problem inputs
problem_inputs;

%% INITIALIZE ITERATION
runs_max = 1; % Number of optimization analyses, in case I want to test different starting points
xVec    = zeros(num_turbines,runs_max);
xoptVec = zeros(num_turbines,runs_max);
AEPvec  = zeros(runs_max,1);
tic
for runs = 1 : runs_max 
    nvar = num_turbines;    % number of variables
    SLPit = 0;
    maxSLPit = 500;
    change = 1;
    % Interpolation
    interp_method = 'SIMP'; % SIMP or RAMP
    p     = 1.25; % SIMP or RAMP parameter
    piter = 5; % every piter iterations update p
    pmax  = 5;
    pstep = 0.25;  % update by +pstep
    pconv = pmax;  % min value of p for accepting termination of opt analysis

    % SLP stuff
    move = .1; % move limit
    A         = [-sparse(ones(1,nvar));      sparse(ones(1,nvar));     to.H_v];
    b         = [-min_vol_frac*nvar; max_vol_frac*nvar; ones(length(to.Hs_v),1)];

    % Starting point
    x    = min([max_vol_frac,1/max(to.Hs_v)]) * ones(nvar,1);

    % Save analysis history
    objVec = zeros(maxSLPit,runs_max);
    while SLPit < maxSLPit

        SLPit = SLPit + 1;
        
        % OBJECTIVE FUNCTION AND SENSITIVITY ANALYSIS
        [xInt, dxInt]  = to.interp_density(x, interp_method, p);
        [AEP, dAEP]    = calc_AEP(xInt, losses, wind, turbine);
        f0val = AEP;
        df0dx = dAEP .* dxInt;
        objVec(SLPit,runs) = -f0val;

        Alp = A;
        blp = b;


        % PRINT RESULTS
        fprintf(' It:%5i Obj:%11.4f ch:%7.4f p:%5.2f xi:%5.2f \n',...
            SLPit, AEP, change, p, xi);

        %% SLP
        lb = max((x-move),1e-6);
        ub = min((x+move),1);
        xold = x;
        %@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%         method = 'simplex';
        method =  'ip';
        
        if (strcmp(method,'simplex') == 1)
            % Solve with simplex
            options = optimset('LargeScale', 'on','Algorithm', 'dual-simplex', 'Display','off');
            [x,objval,exit_flag,output,lambda] = ...
                linprog(df0dx, Alp, blp, [], [], lb, ub, options);
        elseif (strcmp(method,'ip') == 1)
            % Solve with interior point
            options = optimset('LargeScale', 'on', 'Algorithm', 'interior-point', 'Display','off');
            [x,objval,exit_flag,output,lambda] = ...
                linprog(df0dx, Alp, blp, [], [], lb, ub, options);
        end
        
        if (exit_flag <= 0)% Problem is infeasible!
           break 
        end
        %@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        
        change = max(abs(x-xold));
        
        % Continuation scheme
        if (p==pconv && xi==ximin) && change <= 1e-6
            break
        else
            % Continuation scheme for parameter xi, wake expansion
            % coefficient (WEC). From Thomas and Ning:
            % Thomas, J. J., & Ning, A. (2018, June). A method for reducing multi-modality in the wind farm layout optimization problem. In Journal of Physics: Conference Series (Vol. 1037, No. 4, p. 042012). IOP Publishing.
            if xi==ximin
                if mod(SLPit,piter)==0
                    p = min([p + pstep,pmax]);
                end
            end
            if mod(SLPit,xiiter)==0
                xiold = xi;
                xi = max([xi - xistep, ximin]);
                if xi ~= xiold
                    losses = calc_losses(turb_coords, wind, turbine, xi);
                end
            end
        end

    end
    xopt = round(x);
    % Calculate final AEP
    losses = calc_losses(turb_coords, wind, turbine, 1);
    [AEP, dAEP]    = calc_AEP(xopt, losses, wind, turbine);
    
    xVec(:,runs)    = x;
    xoptVec(:,runs) = xopt;
    AEPvec(runs)    = -AEP;
end
time_elapsed = toc

%% Extract best solution
[AEP, idMax] = max(AEPvec);
x            = xVec(:,idMax);
xopt         = xoptVec(:,idMax);
objOpt       = objVec(1:SLPit,idMax);

save(resFolder+"opt_sol_SLP.mat", 'x', 'xopt', 'losses', 'wind', 'turbine', 'turb_coords', 'AEP', 'objOpt')

sz = 1+round(sz0 * xopt);
figure;
hold on
scatter(turb_coords.x, turb_coords.y, sz, 'filled');
xlabel('x [m]')
ylabel('y [m]')
title('Optimized wind farm layout')
for i=1:length(xopt)
    if xopt(i) == 1
        p = nsidedpoly(1000, 'Center', [turb_coords.x(i) turb_coords.y(i)], 'Radius', turbine.diameter*2);
        plot(p, 'EdgeColor','red','FaceColor','none', 'LineWidth', .5)
    end
end
axis equal; drawnow;
set(gca,'FontSize',15)
filename = resFolder+"optimized_wind_farm_layout_slp.png";
saveas(gcf, filename, 'png')
hold off

fprintf(' Turbines num.: %5.1f, Min turbines: %5.1f, Max turbines: %5.1f AEP:%9.4f GWh\n',...
    sum(xopt), min_num_turbines, max_num_turbines, AEP);

% Plot wind farm wakes
plot_wind_farm(xopt, wind, turb_coords, turbine, "SLP", resFolder)

% Stop recording command window to log file
diary off

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