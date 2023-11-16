function addPlotOrbit(kepEl, mu, thf, stepTh)

a = kepEl(1);
e = kepEl(2);
i = kepEl(3);
OM = kepEl(4);
om = kepEl(5);
th0 = kepEl(6);

%[r0, ~] = kep2car (a, e, i, OM, om, th0, mu);

if thf >= th0
    th = th0:stepTh:thf;
else
    th = th0:stepTh:thf+360;
end

r = zeros(3, length(th));

for j = 1 : length(th)
    [r(:,j), ~] = kep2car (a, e, i, OM, om, th(j), mu);
end

X = r(1, :);
Y = r(2, :);
Z = r(3, :);

plot3(X, Y, Z, 'LineWidth', 2)
%plot3(r0(1), r0(2), r0(3),'xr', 'LineWidth', 1)

end