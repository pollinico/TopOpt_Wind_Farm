function turb_coord = wind_farm_ground_structure(type, Xmin, Xmax, Xstep, Ymin, Ymax, Ystep)
x = (Xmin:Xstep:Xmax);
y = (Ymin:Ystep:Ymax);

[X,Y] = meshgrid(x,y);
turb_coord.X = X;
turb_coord.Y = Y;

if strcmp(type, 'rectangular')
    turb_coord.x = X(:);
    turb_coord.y = Y(:);
elseif strcmp(type, 'circular')
    x = X(:);
    y = Y(:);
    j = 0;
    for i=1:length(x)
        if sqrt(x(i)^2 + y(i)^2) <= Xmax
            j = j+1;
            turb_coord.x(j) = x(i);
            turb_coord.y(j) = y(i);
        end
    end
    
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