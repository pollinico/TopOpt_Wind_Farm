function losses = calc_losses(turb_coords, wind, turbine, xi)

num_turbines = length(turb_coords.x);
num_bins = length(wind.bins);
losses = zeros(num_turbines*num_bins, num_turbines);
turb_diam = 2*turbine.radius;
for i = 1 : num_bins
    % Shift coordinate frame of reference to downwind/crosswind
    frame_coords = WindFrame(turb_coords, wind.bins(i));
    % Use the Simplified Bastankhah Gaussian wake model for wake deficits
    start_indx = (i-1) * num_turbines + 1;
    end_indx   = i * num_turbines;
    losses(start_indx : end_indx, :) = GaussianWake(frame_coords);
end


    function loss = GaussianWake(frame_coords)
        % Return each turbine's total loss due to wake from upstream turbines%
        % Equations and values explained in <iea37-wakemodel.pdf>
        num_turb = length(frame_coords.x);
        % Constant thrust coefficient
        CT = 4 * 1/3 *(1 - 1/3);
        % Constant, relating to a turbulence intensity of 0.075
        k = 0.0324555;
        % Array holding the wake deficit seen at each turbine
        loss = zeros(num_turb, num_turb);
        for ii = 1 : num_turb
            for jj = 1 : num_turb
                x = frame_coords.x(ii) - frame_coords.x(jj);               % Calculate the x-dist
                y = frame_coords.y(ii) - frame_coords.y(jj);               % And the y-offset
                if x > 0                                                   % If Primary is downwind of the Target
                    sigma = k*x + turb_diam/sqrt(8.);                      % Calculate the wake loss
                    % Simplified Bastankhah Gaussian wake model
                    exponent = -0.5 * ( y / (sigma*xi) )^2;
                    radical = 1 - CT/(8 * sigma^2 / turb_diam^2);
                    loss(ii,jj) = (1 - sqrt(radical)) * exp(exponent);
                end
            end
        end
    end

    function  frame_coords = WindFrame(turb_coords, wind_dir_deg)
        % Convert map coordinates to downwind/crosswind coordinates
        % Convert from meteorological polar system (CW, 0 deg.=N)
        % to standard polar system (CCW, 0 deg.=W)
        % Shift so North comes "along" x-axis, from left to right.
        wind_dir_deg = 270 - wind_dir_deg;
        % Convert inflow wind direction from degrees to radians
        wind_dir_rad = deg2rad(wind_dir_deg);
        % Constants to use below
        cos_dir = cos(-wind_dir_rad);
        sin_dir = sin(-wind_dir_rad);
        % Convert to downwind(x) & crosswind(y) coordinates
        frame_coords.x = (turb_coords.x * cos_dir) - (turb_coords.y * sin_dir);
        frame_coords.y = (turb_coords.x * sin_dir) + (turb_coords.y * cos_dir);
    end


end

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