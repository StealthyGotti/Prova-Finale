function [dv, thm ,thf, dt] = changePerArg (a, e, wi, wf, thi)

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

dt = flightTime (a, e, rad2deg(thi), rad2deg(thm));

thf = thm - dw;
if thf < 0
    thf = 2*pi + thf;
elseif thf > 2*pi
    thf = thf - 2*pi;
end

thm = rad2deg(thm);
thf = rad2deg(thf);

end