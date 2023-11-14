function [X, Y, Z] = plotOrbit(kepEl, mu, deltaTh, stepTh)

% plotOrbit.m - Plot the arc length deltaTh of the orbit described by
% kepEl.
%
% PROTOTYPE:
% plotOrbit(kepEl, mu, deltaTh, stepTh)
%
% DESCRIPTION:
% Plot the arc length of the orbit described by a set of orbital
% elements for a specific arc length.
%
% INPUT:
% kepEl [1x6] orbital elements [km,rad]
% mu [1x1] gravitational parameter [km^3/s^2]
% deltaTh [1x1] arc length [rad]
% stepTh [1x1] arc length step [rad]
%
% OUTPUT:
% X [1xn] X position [km]
% Y [1xn] Y position [km]
% Z [1xn] Z position [km]

a = kepEl(1);
e = kepEl(2);
i = kepEl(3);
OM = kepEl(4);
om = kepEl(5);
th = kepEl(6):stepTh:kepEl(6)+deltaTh;

r = zeros(3, length(th));

for j = 1 : length(th)
    [r(:,j), ~] = kep2car (a, e, i, OM, om, th(j), mu);
end

X = r(1, :);
Y = r(2, :);
Z = r(3, :);