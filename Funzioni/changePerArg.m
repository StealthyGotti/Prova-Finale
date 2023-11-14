function [dv, thf, dt] = changePerArg (a, e, wi, wf, thi)

wi = deg2rad(wi);
wf = deg2rad(wf);
thi = deg2rad(thi);

mu = 398600;

dw = wf - wi;

if dw < 0
    th1 = dw/2 + pi;
    th2 = dw/2 + 2*pi;
elseif dw > 0
    th1 = dw/2;
    th2 = dw/2 + pi;
else
    error('Nothing to change')
end

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
dv = 2*sqrt(mu/p)*e*sin(abs(thm));

dt = flightTime (a, e, thi, thm);

thf = thm + dw;
if thf < 2*pi
    thf = thf - 2*pi;
end

thf = rad2deg(thf);

end