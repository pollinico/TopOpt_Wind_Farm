function wind = wind_input()
    wind.bins = [0.0, 22.5, 45.0, 67.5,...
               90.0, 112.5, 135.0, 157.5,...
               180.0, 202.5, 225.0, 247.5,...
               270.0, 292.5, 315.0, 337.5]; % deg, The wind direction in degree, with North as the 0. 16 bins
    
    wind.speed = 9.8; % m/s, A wind speed, constant for these case studies
    
    wind.ti = 0.075; % turbulence intensity
    
    wind.freq = [.025,  .024,  .029,  .036,...
                    .063,  .065,  .100,  .122,...
                    .063,  .038,  .039,  .083,...
                    .213,  .046,  .032,  .022]; % Wind directional frequency distribution for 16 bins of wind rose


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