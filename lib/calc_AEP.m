function [AEP,dAEP] = calc_AEP(x, losses, wind, turbine)
%Calculate the wind farm AEP
num_bins = length(wind.bins);                                               % Number of bins used for our windrose
num_turbines = size(losses, 1) / num_bins;
%  Power produced by the wind farm from each wind direction
pwr_produced = zeros(num_bins, 1);
dpwr_produced = zeros(num_bins, num_turbines);
% For each wind bin
for i = 1 : num_bins
    start_indx = (i-1)*num_turbines + 1;
    end_indx = i*num_turbines;
    [pwr_produced(i), dpwr_produced(i,:)] = dir_power(losses(start_indx:end_indx, :));
end

%  Convert power to AEP
hrs_per_year = 365.0 * 24.0;
AEP = hrs_per_year * (wind.freq * pwr_produced);
dAEP = hrs_per_year * (wind.freq * dpwr_produced);
AEP = -AEP / 1.E9;  % Convert to GWh
dAEP = -dAEP' / 1.E9;

if ~isreal(AEP)
    keyboard;
end

    function [pwr,dpwr] = dir_power(loss)
        turb_pwr = zeros(num_turbines,1);
        dturb_pwr = 1e-8*ones(num_turbines,num_turbines);
        % approach 1 [ (x*loss)^2 ] 
%         wind_speed_eff = wind.speed*( 1. - sqrt( sum((repmat(x',num_turbines,1).*loss).^2, 2) ) );
%         dwind_speed_eff = -(0.5 * wind.speed ./ repmat(sqrt( sum((1e-20+repmat(x',num_turbines,1).*loss).^2, 2) ),1,num_turbines)) .* 2 .* repmat(x',num_turbines,1) .* loss.^2;
        % approach 2 [ x*loss^2 ]
        wind_speed_eff = wind.speed*( 1. - sqrt( sum(repmat(x',num_turbines,1).*loss.^2, 2) ) );
        dwind_speed_eff = -(0.5 * wind.speed ./ repmat(sqrt( sum(1e-20+repmat(x',num_turbines,1).*loss.^2, 2) ),1,num_turbines)) .* loss.^2;
        for ii = 1:num_turbines
            if (turbine.cutin_ws <= wind_speed_eff(ii)) && (wind_speed_eff(ii) <= turbine.rated_ws)
                
                % Calculate the curve's power
                turb_pwr(ii) = turbine.rated_pwr * ((wind_speed_eff(ii)-turbine.cutin_ws)...
                    / (turbine.rated_ws-turbine.cutin_ws))^3;
                dturb_pwr(ii,:) = turbine.rated_pwr * 3 * ((wind_speed_eff(ii)-turbine.cutin_ws)...
                    / (turbine.rated_ws-turbine.cutin_ws))^2 * dwind_speed_eff(ii,:)/ (turbine.rated_ws-turbine.cutin_ws);
            elseif  (turbine.rated_ws <= wind_speed_eff(ii)) &&  (wind_speed_eff(ii)<= turbine.cutout_ws)
                
                % Rtaed power
                turb_pwr(ii) = turbine.rated_pwr;
                
            end
        end
        pwr = sum(x.*turb_pwr);
        dpwr = turb_pwr + (x'*dturb_pwr)';
    end
end