function [r, v] = kep2car (a, e, i, OM, om, th, mu)

i = deg2rad(i);
OM = deg2rad(OM);
om = deg2rad(om);
th = deg2rad(th);

p = a*(1-e^2);
r = p/(1+e*cos(th));
re = r*cos(th);
rp = r*sin(th);
ve = -sqrt(mu/p)*sin(th);
vp = sqrt(mu/p)*(e+cos(th));

% Rw = [cos(w) sin(w) 0
%      -sin(w) cos(w) 0
%       0      0      1];
% Ri = [1      0      0
%       0      cos(i) sin(i)
%       0     -sin(i) cos(i)];
% RW = [cos(W) sin(W) 0
%      -sin(W) cos(W) 0
%       0      0      1];
% 
% R = transpose(Rw*Ri*RW);

R = [cos(om)*cos(OM)-sin(om)*cos(i)*sin(OM), -sin(om)*cos(OM)-cos(om)*cos(i)*sin(OM),  sin(i)*sin(OM);
     cos(om)*sin(OM)+sin(om)*cos(i)*cos(OM), -sin(om)*sin(OM)+cos(om)*cos(i)*cos(OM), -sin(i)*cos(OM);
     sin(om)*sin(i),                          cos(om)*sin(i),                          cos(i)         ];

pos = R*[re; rp; 0];
vel = R*[ve; vp; 0];

x = pos(1);
y = pos(2);
z = pos(3);
r = [x; y; z];

vx = vel(1);
vy = vel(2);
vz = vel(3);
v = [vx; vy; vz];

end