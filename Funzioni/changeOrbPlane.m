function [dv, wf, thf, dt] = changeOrbPlane (a, e, iin, Wi, wi, ifin, Wf, thi)

iin = deg2rad(iin);
Wi = deg2rad(Wi);
wi = deg2rad(wi);
ifin = deg2rad(ifin);
Wf = deg2rad(Wf);
thi = deg2rad(thi);

mu = 398600;

dW = Wf - Wi;
di = ifin - iin;

if dW > 0 && di >= 0
    alpha = acos(cos(iin)*cos(ifin)+sin(iin)*sin(ifin)*cos(dW));
    ui = asin(sin(ifin)*sin(dW)/sin(alpha));
    uf = asin(sin(iin)*sin(dW)/sin(alpha));
    if ui >= wi
        thm = ui - wi;
    elseif ui < wi
        thm = 2*pi + (ui - wi);
    end
    thf = thm;
    if uf >= thf
        wf = uf - thf;
    elseif uf < thf
        wf = 2*pi + (uf - thf);
    end
elseif dW > 0 && di < 0
    alpha = acos(cos(iin)*cos(ifin)+sin(iin)*sin(ifin)*cos(dW));
    ui = asin(-sin(ifin)*sin(dW)/sin(alpha));
    uf = asin(-sin(iin)*sin(dW)/sin(alpha));
    if ui >= wi
        thm = ui - wi;
    elseif ui < wi
        thm = 2*pi + (ui - wi);
    end
    thf = thm;
    if uf >= thf
        wf = uf - thf;
    elseif uf < thf
        wf = 2*pi + (uf - thf);
    end
elseif dW < 0 && di >= 0
    alpha = acos(cos(iin)*cos(ifin)+sin(iin)*sin(ifin)*cos(dW));
    ui = asin(sin(ifin)*sin(dW)/sin(alpha));
    uf = asin(sin(iin)*sin(dW)/sin(alpha));
    if ui >= wi
        thm = ui - wi;
    elseif ui < wi
        thm = 2*pi + (ui - wi);
    end
    thf = thm;
    if uf >= thf
        wf = uf - thf;
    elseif uf < thf
        wf = 2*pi + (uf - thf);
    end
elseif dW < 0 && di < 0
    alpha = acos(cos(iin)*cos(ifin)+sin(iin)*sin(ifin)*cos(dW));
    ui = asin(-sin(ifin)*sin(dW)/sin(alpha));
    uf = asin(-sin(iin)*sin(dW)/sin(alpha));
    if ui >= wi
        thm = ui - wi;
    elseif ui < wi
        thm = 2*pi + (ui - wi);
    end
    thf = thm;
    if uf >= thf
        wf = uf - thf;
    elseif uf < thf
        wf = 2*pi + (uf - thf);
    end
elseif dW == 0 && di ~= 0
    error('Use changeIncl instead')
elseif dW == 0 && di == 0
    error('Nothing to change here')
end

th1 = thm;
th2 = thm + pi;

if (thi < th1 && thi < th2) || (thi > th1 && thi > th2)
    thm = th1;
elseif thi > th1 && thi < th2
    thm = th2;
elseif thi == th1
    thm = th1;
elseif thi == th2
    thm = th2;
end

p = a*(1-e^2);
dv = 2*sqrt(mu/p)*(1+e*cos(thm))*sin(alpha/2);

dt = flightTime (a, e, rad2deg(thi), rad2deg(thm));

thf = thm;

wf = rad2deg(wf);
thf = rad2deg(thf);

end