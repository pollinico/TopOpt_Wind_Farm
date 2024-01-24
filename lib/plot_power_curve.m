close all;
clear all;
clc;
commandwindow;


turbine = turbine_input();

ws_vec   = (turbine.cutin_ws:.1:turbine.cutout_ws);
turb_pwr = zeros(size(ws_vec));

for ii = 1:length(ws_vec)
    if (turbine.cutin_ws <= ws_vec(ii)) && (ws_vec(ii)<= turbine.rated_ws)
        
        % Calculate the curve's power
        turb_pwr(ii) = turbine.rated_pwr * ((ws_vec(ii)-turbine.cutin_ws)...
            / (turbine.rated_ws-turbine.cutin_ws))^3;
    elseif  (turbine.rated_ws <= ws_vec(ii)) &&  (ws_vec(ii)<= turbine.cutout_ws)
        % Rtaed power
        turb_pwr(ii) = turbine.rated_pwr;
        
    end
end


figure;
hold on
grid on
plot(ws_vec,turb_pwr/1e6, 'LineWidth',2)
xlabel('ws [m/s]')
ylabel('P [MW]')
set(gca,'FontSize',13)
pbaspect([2 1 1])
hold off

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