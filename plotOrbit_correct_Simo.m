function [X , Y , Z] = plotOrbit_correct_Simo(a , e , i_dg , OM , om , mu , n)

T = 2*pi*sqrt((a^3)/mu);
t = linspace(0 , n*T , 1000);
M = t*sqrt(mu/a^3);

x = linspace(0,2*n*pi,size(t,2));
E = zeros(1,size(M,2));
x0 = linspace(0,2*n*pi,size(t,2));

for i = 1:size(M,2)
    fun = @(x) x - e * sin(x) - M(i);
    dfun = @(x) 1 - e* cos(x);
    toll = 1e-8;
    [xvect,it]=newton(x0(i),1000,toll,fun,dfun);
    E(i) = xvect(end);
end

E_dg = E*(180/pi);
plot(t,E_dg);

theta = 2 * atan( sqrt((1+e)/(1-e)) * tan(E/2) ); 
theta_dg = theta*(180/pi);
plot(t,theta_dg);

plot(t,E_dg,t,theta_dg);

deltaTh = size(E,2)
stepTh = E(end);

R = zeros(3,size(theta,2));

kepEl = [a, e, i_dg , OM , om , mu] ;

for i = 1:size(theta,2)
    [r,v] = kep2car_simo( kepEl(1,1), kepEl(1,2), kepEl(1,3), kepEl(1,4), kepEl(1,5), theta(i), kepEl(1,6) );
    R(:,i) = r;
end
R;

X = R(1,:);
Y = R(2,:);
Z = R(3,:);

% Call the Terra_3D Function
Terra3d
hold on;
% Plot the 3D satellite orbit
plot3(X,Y,Z)
% Define an indefinite plot
h = plot3(nan,nan,nan,'or');

xlabel('X [km]');
ylabel('Y [km]');
zlabel('Z [km]');

grid on;
 
title('Orbita satellite')

% Define the step animation
step_animation = 1;
% Define the moving point
for i = 1:step_animation:length(X)
set( h,'XData',X(i),'YData',Y(i),'ZData',Z(i));
drawnow
end