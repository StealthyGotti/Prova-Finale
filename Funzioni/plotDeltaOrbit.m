function [X, Y, Z] = plotDeltaOrbit(kepEl, mu, deltaTh, stepTh)

deltaTh = deg2rad(deltaTh);
stepTh = deg2rad(stepTh);

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

end