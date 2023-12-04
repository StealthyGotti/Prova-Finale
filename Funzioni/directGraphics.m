function directGraphics (d1, d2, dth, et, th1t, th2t)

dth = deg2rad(dth);
th1t = deg2rad(th1t);
th2t = deg2rad(th2t);

theta1t = linspace(-2*pi, 2*pi, 100);
theta2t = linspace(-2*pi, 2*pi, 100);

[Theta1t, Theta2t] = meshgrid(theta1t, theta2t);

eq1 = d2*(1 + et*cos(Theta2t)) - d1*(1 + et*cos(Theta1t));
eq2 = Theta2t - Theta1t - dth;

Z = zeros(size(Theta1t));

figure

colormap("winter")
hold on
grid on
surf(Theta1t, Theta2t, eq1, 'EdgeColor', 'none', 'FaceAlpha', 0.7)
surf(Theta1t, Theta2t, eq2, 'EdgeColor', 'none', 'FaceAlpha', 0.7)
surf(Theta1t, Theta2t, Z, 'EdgeColor', 'none', 'FaceAlpha', 0.3)
plot3(theta1t, theta2t+dth, zeros(size(theta1t)), 'w', 'LineWidth', 0.5)
plot3(theta1t+2*pi, theta2t+dth, zeros(size(theta1t)), 'w', 'LineWidth', 0.5)
plot3(th1t, th2t, 0,  'k.', 'MarkerSize', 30)

xlabel('\theta_{1t}');
ylabel('\theta_{2t}');
zlabel('z');
xlim([0 2*pi])
ylim([0 2*pi])

view(30, 30)

title('Graphical representation of solution for direct transfer orbit maneuvering anomalies');

legend('$d_2(1 + e \cos(\theta_{2t})) - d_1(1 + e \cos(\theta_{1t})) = 0$', ...
       '$\theta_{2t} - \theta_{1t} - \Delta \theta = 0$', ...
       '$z = 0$', 'Interpreter', 'latex');

end