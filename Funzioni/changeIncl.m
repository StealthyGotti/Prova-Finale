function [dv, thf, dt] = changeIncl (a, e, w, iin, ifin, thi)

mu = 398600;

di = ifin - iin;

th1 = 2*pi - w;
th2 = (2*pi - w) + pi;

if (thi > th1 && thi > th2) || (thi < th1 && thi < th2)
    thm = th1;
elseif thi > th1 && thi < th2
    thm = th2;
elseif thi == th1
    thm = th1;
elseif thi == th2
    thm = th2;
end

p = a*(1-e^2);
dv = 2*sqrt(mu/p)*(1+e*cos(thm))*sin(abs(di)/2);

dt = flightTime (a, e, thi, thm);

thf = thm;