function [r,v] = kep2car_simo(a, e, i, OM, om, th, mu)
% kep2car.m - Conversion from Keplerian elements to Cartesian coordinates
%
% PROTOTYPE:
% [r, v] = kep2car(a, e, i, OM, om, th, mu)
%
% DESCRIPTION:
% Conversion from Keplerian elements to Cartesian coordinates. Angles in
% radians.
%
% INPUT:
% a [1x1] Semi-major axis [km]
% e [1x1] Eccentricity [-]
% i [1x1] Inclination [rad]
% OM [1x1] RAAN [rad]
% om [1x1] Pericentre anomaly [rad]
% th [1x1] True anomaly [rad]
% mu [1x1] Gravitational parameter [km^3/s^2]
%
% OUTPUT:
% r [3x1] Position vector [km]
% v [3x1] Velocity vector [km/s]

% 1) 
p = a*(1-e^2);
r1 = p/(1+e*cos(th));

% 2)
r2 = r1*[ cos(th) ; sin(th) ; 0 ];
v2 = sqrt(mu/p)*[-sin(th) ; e + cos(th) ; 0];

% 3)

R = [cos(om)*cos(OM)-sin(om)*cos(i)*sin(OM) , -sin(om)*cos(OM)-cos(om)*cos(i)*sin(OM) , sin(i)*sin(OM)
     cos(om)*sin(OM) + sin(om)*cos(i)*cos(OM) , -sin(om)*sin(OM)+cos(om)*cos(i)*cos(OM) , -sin(i)*cos(OM)
     sin(om)*sin(i) , cos(om)*sin(i) , cos(i)];

r = R*r2;
v = R*v2;




