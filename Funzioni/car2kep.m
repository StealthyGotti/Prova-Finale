function [ a , e , i , OM , om , th ] = car2kep(r , v , mu)
% Introduzione che mi manda ora il simo
% car2kep.m - Conversion from Cartesian coordinates to Keplerian elements
%
% PROTOTYPE:
% [a, e, i, OM, om, th] = car2kep(r, v, mu)
%
% DESCRIPTION:
% Conversion from Cartesian coordinates to Keplerian elements. Angles in
% radians.
%
% INPUT:
% r [3x1] Position vector [km]
% v [3x1] Velocity vector [km/s]
% mu [1x1] Gravitational parameter [km^3/s^2]
%
% OUTPUT:
% a [1x1] Semi-major axis [km]
% e [1x1] Eccentricity [-]
% i [1x1] Inclination [rad]
% OM [1x1] RAAN [rad]
% om [1x1] Pericentre anomaly [rad]
% th [1x1] True anomaly [rad]

h = cross(r,v);
i = acos(h(3)/norm(h));
e = 1/mu*( (norm(v).^2 - mu/norm(r))*r - dot(r,v)*v );
E = 0.5*norm(v)^2 - mu/norm(r);
a = -mu/(2*E);
N = cross( [ 0, 0,1 ] , h);

if N(2) >= 0
    OM = acos(N(1)/norm(N));
else
    OM = 2*pi - acos(N(1)/norm(N));
end

if e(3) >= 0
    om = acos(dot(N,e)/(norm(N)*norm(e)));
else
    om = 2*pi - acos(dot(N,e)/(norm(N)*norm(e)));
end

if (dot(r,v)/norm(r))>=0
    th = acos( dot(e,r) / (norm(e)*norm(r)));
else
    th = 2*pi - acos( dot(e,r) / (norm(e)*norm(r)));
end

e = norm(e);

