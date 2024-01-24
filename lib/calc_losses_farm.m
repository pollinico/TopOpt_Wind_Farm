function [point_coords, losses] = calc_losses_farm(turb_coords, wind, turbine)
xi = 1;
xmin = min(turb_coords.x) * 1.1;
xmax = max(turb_coords.x) * 1.1;
ymin = min(turb_coords.y) * 1.1;
ymax = max(turb_coords.y)* 1.1;
[Xpoints, Ypoints] = meshgrid((xmin:(xmax-xmin)/150:xmax),(ymin:(ymax-ymin)/150:ymax));
point_coords.X = Xpoints;
point_coords.Y = Ypoints;
point_coords.x = Xpoints(:);
point_coords.y = Ypoints(:);

num_points = length(Xpoints(:));
num_turbines = length(turb_coords.x);
num_bins = length(wind.bins);
losses = zeros(num_points*num_bins, num_turbines);
turb_diam = 2*turbine.radius;
for i = 1 : num_bins
    % Shift coordinate frame of reference to downwind/crosswind
    frame_coords_t = WindFrame(turb_coords, wind.bins(i));
    frame_coords_p = WindFrame(point_coords, wind.bins(i));
    % Use the Simplified Bastankhah Gaussian wake model for wake deficits
    start_indx = (i-1)*num_points + 1;
    end_indx = i*num_points;
    losses(start_indx : end_indx, :) = GaussianWake();
end


    function loss = GaussianWake()
        % Return each turbine's total loss due to wake from upstream turbines%
        % Constant thrust coefficient
        CT = 4 * 1/3 *(1 -1/3);
        % Constant, relating to a turbulence intensity of 0.075
        k = 0.0324555;
        % Array holding the wake deficit seen at each turbine
        loss = zeros(num_points, num_turbines);
        for ii = 1 : num_points
            for jj = 1 : num_turbines
                x = frame_coords_p.x(ii) - frame_coords_t.x(jj);               % Calculate the x-dist
                y = frame_coords_p.y(ii) - frame_coords_t.y(jj);               % And the y-offset
                if x > 0                                                   % If Primary is downwind of the Target
                    sigma = k*x + turb_diam/sqrt(8.);                          % Calculate the wake loss
                    % Simplified Bastankhah Gaussian wake model
                    exponent = -0.5 * ( y / (sigma*xi) )^2;
                    radical = 1 - CT/(8 * sigma^2 / turb_diam^2);
                    loss(ii,jj) = (1 - sqrt(radical)) * exp(exponent);
                end
                
            end
            
        end
    end

    function  frame_coords = WindFrame(coords, wind_dir_deg)
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
        frame_coords.x = (coords.x * cos_dir) - (coords.y * sin_dir);
        frame_coords.y = (coords.x * sin_dir) + (coords.y * cos_dir);
    end


end