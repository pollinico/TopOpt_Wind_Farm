function [] = plot_wind_farm(x, wind, turb_coords, turbine, type, folder)
[point_coords, losses] = calc_losses_farm(turb_coords, wind, turbine);
%Calculate the wind farm AEP
num_bins = length(wind.bins);                                               % Number of bins used for our windrose
num_points = length(point_coords.x);
% For each wind bin
for i = 1 : num_bins
    start_indx = (i-1)*num_points + 1;
    end_indx = i*num_points;
    wsp = wsp_calc(losses(start_indx:end_indx, :));
    figure;
    hold on
    contourf(point_coords.X, point_coords.Y, reshape(wsp,size(point_coords.X)), 'edgecolor', 'none')
    colormap('jet')
    axis equal;
    c = colorbar('eastoutside');
    c.Ruler.TickLabelFormat='%.0f m/s';
    caxis([3 9])
    xlabel('x [m]')
    ylabel('y [m]')
    set(gca,'FontSize',15)
    title('wind direction \theta = '+string(wind.bins(i))+ ' deg')
    filename = folder + "wind_farm_" + string(wind.bins(i))+ "_deg_" + type + ".png";
    saveas(gcf, filename, 'png')
    hold off
end


    function wsp = wsp_calc(loss)
        wsp = wind.speed*( 1. - sqrt( sum(repmat(x',num_points,1).*loss.^2, 2) ) );
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