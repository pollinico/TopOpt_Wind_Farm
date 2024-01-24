function turb_coord = wind_farm_radial_ground_structure(Rmin, Rmax, Rstep, Qmin, Qmax, Qstep)
r = (Rmin:Rstep:Rmax); % radius
q = (Qmin:Qstep:Qmax); % angle

[R,Q] = meshgrid(r,q);
X = R .* cosd(Q);
Y = R .* sind(Q);
turb_coord.X = X;
turb_coord.Y = Y;

turb_coord.x = X(:)';
turb_coord.y = Y(:)';

end