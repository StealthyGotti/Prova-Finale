function [dv, dt, kepElt1, kepElt2, thm, thfb, axis] = biEllipticChangeOrb (kepEli, kepElf, rb, skip)

ai = kepEli(1);
ei = kepEli(2);
iin = kepEli(3);
Wi = kepEli(4);
wi = kepEli(5);
thi = kepEli(6);
af = kepElf(1);
ef = kepElf(2);
ifin = kepElf(3);
Wf = kepElf(4);
wf = kepElf(5);
thf = kepElf(6);

iin = deg2rad(iin);
Wi = deg2rad(Wi);
wi = deg2rad(wi);
thi = deg2rad(thi);
ifin = deg2rad(ifin);
Wf = deg2rad(Wf);
wf = deg2rad(wf);
thf = deg2rad(thf);

mu = 398600;

sh = 6378 + 100; % safety height
if rb < sh
    error('Below safety height')
end

% Finding maneuver anomaly
di = ifin - iin;
dW = Wf - Wi;
%dw = wf - wi;
if dW > 0 && di >= 0
    alpha = acos(cos(iin)*cos(ifin)+sin(iin)*sin(ifin)*cos(dW));
    ui = asin(sin(ifin)*sin(dW)/sin(alpha));
    %uf = asin(sin(iin)*sin(dW)/sin(alpha));
    if ui >= wi
        thm = ui - wi;
    elseif ui < wi
        thm = 2*pi + (ui - wi);
    end
elseif dW > 0 && di < 0
    alpha = acos(cos(iin)*cos(ifin)+sin(iin)*sin(ifin)*cos(dW));
    ui = asin(-sin(ifin)*sin(dW)/sin(alpha));
    %uf = asin(-sin(iin)*sin(dW)/sin(alpha));
    if ui >= wi
        thm = ui - wi;
    elseif ui < wi
        thm = 2*pi + (ui - wi);
    end
elseif dW < 0 && di >= 0
    alpha = acos(cos(iin)*cos(ifin)+sin(iin)*sin(ifin)*cos(dW));
    ui = asin(sin(ifin)*sin(dW)/sin(alpha));
    %uf = asin(sin(iin)*sin(dW)/sin(alpha));
    if ui >= wi
        thm = ui - wi;
    elseif ui < wi
        thm = 2*pi + (ui - wi);
    end
elseif dW < 0 && di < 0
    alpha = acos(cos(iin)*cos(ifin)+sin(iin)*sin(ifin)*cos(dW));
    ui = asin(-sin(ifin)*sin(dW)/sin(alpha));
    %uf = asin(-sin(iin)*sin(dW)/sin(alpha));
    if ui >= wi
        thm = ui - wi;
    elseif ui < wi
        thm = 2*pi + (ui - wi);
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
if thm < 0
    thm = 2*pi + thm;
elseif thm >= 2*pi
    thm = 2*pi - thm;
end
if nargin == 4 && strcmp(skip, 'skip')
    if thm == th1
        thm = th2;
    elseif thm == th2
        thm = th1;
    end
end

% Reaching maneuvering position
dt0 = flightTime (af, ef, rad2deg(thi), rad2deg(thm));

% Retrieving initial position and velocity data (ECI)
[ri, vi] = kep2car(ai, ei, rad2deg(iin), rad2deg(Wi), rad2deg(wi), rad2deg(thm), mu);

% Finding intersection line (versor) between initial and final orbital planes (ECI)
axis = ri/norm(ri);

% Evaluating intial orbit h vector (ECI)
hi = cross(ri,vi);

% Understanding if rb will be major or minor semiaxis for first trasfer orbit
if rb >= norm(ri)
    rpt1 = norm(ri);
    rat1 = rb;
    ctr1 = 0;
elseif rb < norm(ri)
    rpt1 = rb;
    rat1 = norm(ri);
    ctr1 = 1;
end

% % Evaluating initial orbit e vector (ECI)
% evecti = cross(vi, hi)/mu - ri/norm(ri);

% Finding vpt1/vat1 (ECI)
at1 = (rpt1+rat1)/2;
pt1 = 2*rpt1*rat1/(rpt1+rat1);
et1 = sqrt(1-pt1/at1);
if ctr1 == 0
    vpt1 = sqrt(mu/pt1)*(1+et1)*cross(hi,axis)/norm(cross(hi,axis));
elseif ctr1 == 1
    vat1 = sqrt(mu/pt1)*(1-et1)*cross(hi,axis)/norm(cross(hi,axis));
end

% Characterizing t1
if ctr1 == 0
    [at1, et1, it1, Wt1, wt1, tht1] = car2kep(ri,vpt1,mu);
elseif ctr1 == 1
    [at1, et1, it1, Wt1, wt1, tht1] = car2kep(ri,vat1,mu);
end
kepElt1 = [at1, et1, it1, Wt1, wt1, tht1];
kepElt1(6) = 0;

% Evaluating 1st impulse
if ctr1 == 0
    dv1 = norm(vpt1-vi);
elseif ctr1 == 1
    dv1 = norm(vat1-vi);
end

% Covering 1st leg
dt1 = pi*sqrt(at1^3/mu);

% Finding vat1/vpt1 (ECI)
if ctr1 == 0
    [~, vat1] = kep2car(at1, et1, it1, Wt1, wt1, 180, mu);
elseif ctr1 == 1
    [~, vpt1] = kep2car(at1, et1, it1, Wt1, wt1, 0, mu);
end

% Finding thfb (true anomaly on final orbit when at the pericenter of second transfer orbit)
[reg, veg] = kep2car(af, ef, rad2deg(ifin), rad2deg(Wf), rad2deg(wf), 0, mu); % e.g. rf and vf to find h
hf = cross(reg,veg);
evectf = cross(veg, hf)/mu - reg/norm(reg);
e = evectf;
h = hf/norm(hf);
p = cross(h,e);
if dot(axis,p) >= 0
    thfb = acos(dot(evectf,axis)/norm(evectf));
elseif dot(axis,p) < 0
    thfb = 2*pi - acos(dot(evectf,axis)/norm(evectf));
end

% Retrieving final position and velocity data (ECI)
[rf, vf] = kep2car(af, ef, rad2deg(ifin), rad2deg(Wf), rad2deg(wf), rad2deg(thfb), mu);

% Understanding if rb will be major or minor semiaxis of second trasfer orbit
if rb >= norm(rf)
    rpt2 = norm(rf);
    rat2 = rb;
    ctr2 = 0;
elseif rb < norm(rf)
    rpt2 = rb;
    rat2 = norm(rf);
    ctr2 = 1;
end

% Finding vpt2/vat2 (ECI)
at2 = (rpt2+rat2)/2;
pt2 = 2*rpt2*rat2/(rpt2+rat2);
et2 = sqrt(1-pt2/at2);
if ctr2 == 0
    vpt2 = sqrt(mu/pt2)*(1+et2)*cross(hf,axis)/norm(cross(hf,axis));
elseif ctr2 == 1
    vat2 = sqrt(mu/pt2)*(1-et2)*cross(hf,axis)/norm(cross(hf,axis));
end

% Characterizing t2
if ctr2 == 0
    [at2, et2, it2, Wt2, wt2, tht2] = car2kep(rf,vpt2,mu);
elseif ctr2 == 1
    [at2, et2, it2, Wt2, wt2, tht2] = car2kep(rf,vat2,mu);
end
kepElt2 = [at2, et2, it2, Wt2, wt2, tht2];
kepElt2(6) = 180;

% Finding vat2/vpt2 (ECI)
if ctr2 == 0
    [~, vat2] = kep2car(at2, et2, it2, Wt2,wt2, 180, mu);
elseif ctr2 == 1
    [~, vpt2] = kep2car(at2, et2, it2, Wt2,wt2, 0, mu);
end

% Evaluating 2nd impulse
if ctr1 == 0 && ctr2 == 0
    dv2 = norm(vat2-vat1);
elseif ctr1 == 0 && ctr2 == 1
    dv2 = norm(vpt2-vat1);
elseif ctr1 == 1 && ctr2 == 0
    dv2 = norm(vat2-vpt1);
elseif ctr1 == 1 && ctr2 == 1
    dv2 = norm(vpt2-vpt1);
end

% Covering 2nd leg
dt2 = pi*sqrt(at2^3/mu);

% Evaluating 3rd impulse
if ctr2 == 0
    dv3 = norm(vf-vpt2);
elseif ctr2 == 1
    dv3 = norm(vf-vat2);
end

% Reaching final position
dt3 = flightTime (af, ef, rad2deg(thfb), rad2deg(thf));

dv = dv1 + dv2 + dv3;
dt = dt0 + dt1 + dt2 + dt3;
thm = rad2deg(thm);
thfb = rad2deg(thfb);

end