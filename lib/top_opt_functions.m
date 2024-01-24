classdef top_opt_functions
    % Container of functions used for top opt of wind farm
    properties
        H1
        Hs1
        H2
        Hs2
        H_v
        Hs_v
    end
    
    methods
        
        function [obj] = loc_vol_filt_II(obj, turb_coords, rmin)
            Nturbine = length(turb_coords.x);
            nfilter = Nturbine*(Nturbine-1);
            iH = sparse(ones(nfilter,1));
            jH = sparse(ones(nfilter,1));
            sH = sparse(zeros(nfilter,1));
            cc = 0;
            for i = 1 : Nturbine
                xi = turb_coords.x(i);
                yi = turb_coords.y(i);
                for j = 1 : Nturbine
                    xj = turb_coords.x(j);
                    yj = turb_coords.y(j);
                    dx = xi-xj;
                    dy = yi-yj;
                    fac = rmin-sqrt((dx^2+dy^2));
                    if fac >= 0 && i~=j
                        % x_i
                        cc = cc+1;
                        iH(cc) = (i-1)*Nturbine + j;
                        jH(cc) = i;
                        sH(cc) = 1.;
                        % x_j
                        cc = cc+1;
                        iH(cc) = (i-1)*Nturbine + j;
                        jH(cc) = j;
                        sH(cc) = 1.;
                    end
                end
            end
            obj.H_v  = sparse(iH,jH,sH);
            obj.H_v( all(~obj.H_v,2), : ) = [];
            obj.Hs_v = sum(obj.H_v, 2);
        end
        
        function [xnew, dxnew] = interp_density(obj, x, method, p)
            if strcmp(method,'SIMP')
                xnew = x.^p;
                dxnew = p*x.^(p-1);
            elseif strcmp(method,'RAMP')
                xnew = x ./ (1 + p*(1-x));
                dxnew = (p+1) ./ (1 + p*(1-x)).^2;
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