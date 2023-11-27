function plotOrbit(kepEl, mu, stepTh, thf, color)

a = kepEl(1);
e = kepEl(2);
i = kepEl(3);
OM = kepEl(4);
om = kepEl(5);
th0 = kepEl(6);

if nargin == 3
    thf = kepEl(6) + 360;
end

%[r0, ~] = kep2car (a, e, i, OM, om, th0, mu);
%[r0, ~] = kep2car (a, e, i, OM, om, thf, mu);

if thf >= th0
    th = th0:stepTh:thf;
    th(end) = thf;
else
    th = th0:stepTh:thf+360;
    th(end) = thf+360;
end

r = zeros(3, length(th));

for j = 1 : length(th)
    [r(:,j), ~] = kep2car (a, e, i, OM, om, th(j), mu);
end

X = r(1, :);
Y = r(2, :);
Z = r(3, :);

if nargin == 5
    plot3(X, Y, Z, 'LineWidth', 2, 'Color', color)
else
    orb = plot3(X, Y, Z, 'LineWidth', 2);
    color = get(orb, 'Color');
end

hold on
[p, ~] = kep2car (a, e, i, OM, om, 0, mu);
[a, ~] = kep2car (a, e, i, OM, om, 180, mu);
plot3(1.5*[p(1) a(1)], 1.5*[p(2) a(2)], 1.5*[p(3) a(3)], 'Color', color, 'LineWidth', 1, 'LineStyle', '--')

%plot3(r0(1), r0(2), r0(3),'xr', 'LineWidth', 1)
%plot3(rf(1), rf(2), rf(3),'xr', 'LineWidth', 1)

end