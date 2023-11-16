function justPlotOrbit(kepEl, mu, stepTh)

a = kepEl(1);
e = kepEl(2);
i = kepEl(3);
OM = kepEl(4);
om = kepEl(5);
th0 = kepEl(6);

[r0, ~] = kep2car (a, e, i, OM, om, th0, mu);

th = 0:stepTh:360;

r = zeros(3, length(th));

for j = 1 : length(th)
    [r(:,j), ~] = kep2car (a, e, i, OM, om, th(j), mu);
end

X = r(1, :);
Y = r(2, :);
Z = r(3, :);

figure

Terra3d

plot3(X, Y, Z, 'LineWidth', 2)
plot3(r0(1), r0(2), r0(3), 'o', 'MarkerSize', 10, 'MarkerEdgeColor', 'r', 'LineWidth', 3)
xlabel('X [km]')
ylabel('Y [km]')
zlabel('Z [km]')

% [x, y] = meshgrid(-1.5*a:50:1.5*a, -a*1.5:50:1.5*a);
% z = zeros(size(x));
% plot3(x, y, z, 'Color', [.7 .7 .7])

% xlim([-3*a 3*a])
% ylim([-3*a 3*a])
% zlim([-3*a 3*a])
view(-30, 30)
grid on
set(gca, 'FontSize', 16)
hold on

end