function [a, e_n , i, OM, om, th] = car2kep_simo(r, v, mu)
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

% 1) Modulo vettore posizione e vettore velocità
r_n = norm(r);
v_n = norm(v);

% 2) Momento angolare specifico
h = cross(r,v);
h_n = norm(h);
hz = h(3,1);

% 3) INCLINAZIONE
i = acos(hz/h_n);

% 4) VETTORE ECCENTRICITA' ED ECCENTRICITA'
e = (1/mu)*(( v_n^2 - mu/r_n).*r - (dot(r,v)).*v);
e_n = norm(e);

% 5) Energia meccanica specifica e SEMIASSE MAGGIORE
E = 0.5*v_n^2 - mu/r_n;
a = -mu/(2*E);

% 6) Linea dei nodi
K = [0;0;1];
N = cross(K,h);
N_n = norm(N);

% 7) ASCENSIONE RETTA DEL NODO ASCENDENTE
Nx = N(1,1);
Ny = N(2,1);

if Ny >= 0
    OM = acos((Nx/N_n));
else 
    OM = 2*pi - acos(Nx/N_n);
end

OM;

% 8) ANOMALIA DEL PERICENTRO
ez = e(3,1);

if ez >= 0
    om = acos(dot(N,e)/(N_n*e_n));
else
    om = 2*pi - cos(dot(N,e)/(N_n*e_n));
end

om;

% 9) VELOCITA' RADIALE
vr = dot(r,v)/r_n;

% 10) ANOMALIA VERA
if vr >= 0
    th = acos(dot(e,r)/(e_n*r_n));
else
    th = 2*pi - acos(dot(e,r)/(e_n*r_n));
end

th;






