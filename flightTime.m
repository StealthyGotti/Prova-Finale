function dt = flightTime (a, e, thi, thf)

thi = deg2rad(thi);
thf = deg2rad(thf);

mu = 398600;

T = 2*pi*sqrt(a^3/mu);

E = 2*atan(sqrt((1-e)/(1+e))*tan(thf/2));
E(E < 0) = E(E < 0) + 2*pi;
t2 = (E-e*sin(E))/(sqrt(mu/a^3));

E = 2*atan(sqrt((1-e)/(1+e))*tan(thi/2));
E(E < 0) = E(E < 0) + 2*pi;
t1 = (E-e*sin(E))/(sqrt(mu/a^3));

if thi <= thf
    dt = t2 - t1;
elseif thi > thf
    dt = T + (t2 - t1);
end

end