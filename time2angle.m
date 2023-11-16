function th = time2angle (t, a, e, mu)

n = sqrt(mu/a^3);
syms E
E = double(vpasolve(n*t == E-e*sin(E), E));

th = 2*atan(tan(E/2)/sqrt((1-e)/(1+e)));

th = rad2deg(th);

end