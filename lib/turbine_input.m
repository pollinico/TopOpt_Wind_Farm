function turbine = turbine_input()

    turbine.radius = 65; % m,  The rotor radius
    
    turbine.diameter = turbine.radius *2;
    
    turbine.rotor = 2.0 * pi * turbine.radius^2.0; % The rotor area

    turbine.height = 110; % m, The hub height
    
    turbine.cutin_ws = 4; % The starting wind speed of the wind turbine
    
    turbine.cutout_ws = 25; % The stopping wind speed of the wind turbine
    
    turbine.rated_ws = 9.8; % The wind speed where the turbine reaches its rated power
    
    turbine.rated_pwr = 3350000.0; % W, The wind turbine electrical power
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