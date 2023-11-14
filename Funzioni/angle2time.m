function t = angle2time (th, a, e, mu)

th = deg2rad(th);

E = 2*atan(sqrt((1-e)/(1+e))*tan(th/2));
E(E < 0) = E(E < 0) + 2*pi;

t = (E-e*sin(E))/(sqrt(mu/a^3));