function [dv, dt, kepElt, th2t, dth, r1, r2, d1, d2, pt, v1, vt1, vt2, v2, dt0, dt1, dt2] = directOrb (kepEli, kepElf, et, thm1, thm2, warnings)

mu = 398600;
Rt = 6378;
sh = Rt + 100; % safety height

% Data extraction
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
if nargin == 3
    thm1 = thi;
    thm2 = thf;
end
if nargin == 5
    warnings = 'on';
end

% Data conversion
iin = deg2rad(iin);
Wi = deg2rad(Wi);
wi = deg2rad(wi);
thi = deg2rad(thi);
ifin = deg2rad(ifin);
Wf = deg2rad(Wf);
wf = deg2rad(wf);
thf = deg2rad(thf);
thm1 = deg2rad(thm1);
thm2 = deg2rad(thm2);

% Covering initial leg
dt0 = flightTime(ai, ei, rad2deg(thi), rad2deg(thm1));

% Finding distance and velocity at thm1
[r1, v1] = kep2car(ai, ei, rad2deg(iin), rad2deg(Wi), rad2deg(wi), rad2deg(thm1), mu);
d1 = norm(r1);

% Finding distance and velocity at thm2
[r2, v2] = kep2car(af, ef, rad2deg(ifin), rad2deg(Wf), rad2deg(wf), rad2deg(thm2), mu);
d2 = norm(r2);

% Characterizing transfer orbit
i = r1/norm(r1);
k = cross(r1,r2)/norm(cross(r1,r2));
if dot(k,cross(r1,v1)) < 0 % setting coherent sense of rotation based on initial orbits
    k = -k; % (specific angular momentum vector will be reversed)
end
j = cross(k,i);
if dot(r2,j) >= 0
    dth = acos(dot(i,r2)/norm(r2));
elseif dot(r2,j) < 0
    dth = 2*pi - acos(dot(i,r2)/norm(r2));
end
if et ~= 0 && d1 ~= d2
    if et ~= 0 && abs(d1-d2) < 1e-6
        if strcmp(warnings,'on')
            warning('Eccentricity could be set to 0 as selected maneuvering distances are equal to each other for %c1 = %.2f°, %c2 = %.2f°, e = %.4f', 952, rad2deg(thm1), 952, rad2deg(thm2), et)
        end
    end
    fun = @(x) [d2*(1 + et*cos(x(2))) - d1*(1 + et*cos(x(1)))
                x(2) - x(1) - dth                            ];
    x0 = [0 0];
    sol = fsolve(fun, x0, optimset('Display', 'off'));
    th1t = sol(1);
    th2t = sol(2);
    if abs(fun(sol)) > 1e-6 % returning NaN values if no solution is found
        dv = NaN;
        dt = NaN;
        kepElt = NaN;
        th2t = NaN; 
        dth = NaN; 
        r1 = NaN; 
        r2 = NaN; 
        d1 = NaN; 
        d2 = NaN; 
        pt = NaN; 
        v1 = NaN; 
        vt1 = NaN; 
        vt2 = NaN; 
        v2 = NaN;
        dt0 = NaN; 
        dt1 = NaN; 
        dt2 = NaN;
        if strcmp(warnings,'on')
            warning('Couldn''t find a solution for %c1 = %.2f°, %c2 = %.2f°, e = %.4f', 952, rad2deg(thm1), 952, rad2deg(thm2), et)
        end
        return
    end
    th1t = rem(th1t, 2*pi);
    if th1t < 0
        th1t = th1t + 2*pi;
    end
    th2t = rem(th2t, 2*pi);
    if th2t < 0
        th2t = th2t + 2*pi;
    end
    pt = d1*(1+et*cos(th1t));
    ht = sqrt(pt*mu);
    ht = ht*k;
    I = [1; 0; 0];
    K = [0; 0; 1];
    it = acos(dot(K, ht)/norm(ht));
    if cross(K, ht) == 0
        Nt = [1; 0; 0];
    else
        Nt = (cross(K, ht))/norm(cross(K, ht));
    end
    if Nt(2) >= 0
        Wt = acos((dot(I, Nt))/norm(Nt));
    elseif Nt(2) < 0
        Wt = 2*pi - acos((dot(I, Nt))/norm(Nt));
    end
    at = pt/(1-et^2);
    et = et*(i*cos(th1t)-j*sin(th1t));
    if et(3) >= 0
        wt = acos((dot(et, Nt))/(norm(et)*norm(Nt)));
    elseif et(3) < 0
        wt = 2*pi - acos((dot(et, Nt))/(norm(et)*norm(Nt)));
    end
elseif et == 0 && abs(d1-d2) >= 1e-6
    dv = NaN;
    dt = NaN;
    kepElt = NaN;
    th2t = NaN; 
    dth = NaN; 
    r1 = NaN; 
    r2 = NaN; 
    d1 = NaN; 
    d2 = NaN; 
    pt = NaN; 
    v1 = NaN; 
    vt1 = NaN; 
    vt2 = NaN; 
    v2 = NaN;
    dt0 = NaN; 
    dt1 = NaN; 
    dt2 = NaN;
    if strcmp(warnings,'on')
        warning('Couldn''t find a solution for %c1 = %.2f°, %c2 = %.2f°, e = %.4f', 952, rad2deg(thm1), 952, rad2deg(thm2), et)
    end
    return
elseif et == 0 && abs(d1-d2) < 1e-6
    pt = d1;
    ht = sqrt(pt*mu);
    ht = ht*k;
    if dot(ht,cross(r1,v1)) < 0
        ht = -ht;
    end
    I = [1; 0; 0];
    K = [0; 0; 1];
    it = acos(dot(K, ht)/norm(ht));
    if cross(K, ht) == 0
        Nt = [1; 0; 0];
    else
        Nt = (cross(K, ht))/norm(cross(K, ht));
    end
    if Nt(2) >= 0
        Wt = acos((dot(I, Nt))/norm(Nt));
    elseif Nt(2) < 0
        Wt = 2*pi - acos((dot(I, Nt))/norm(Nt));
    end
    at = pt;
    wt = 0;
    i = Nt;
    j = cross(k,i);
    if dot(r1,j) >= 0
        th1t = acos(dot(i,r1)/norm(r1));
    elseif dot(r1,j) < 0
        th1t = 2*pi - acos(dot(i,r1)/norm(r1));
    end
    th2t = th1t + dth;
    if dot(ht,cross(r1,v1)) < 0
        [th1t, th2t] = deal(th2t, th1t);
    end
end
et = norm(et);
rpt = at*(1-et);
if rpt < sh
    if strcmp(warnings,'on')
        warning('Possible Earth collision for %c1 = %.2f°, %c2 = %.2f°, e = %.4f', 952, rad2deg(thm1), 952, rad2deg(thm2), et)
    end
end
kepElt = [at, et, rad2deg(it), rad2deg(Wt), rad2deg(wt), rad2deg(th1t)];

% Evaluating first impulse
[~, vt1] = kep2car(at, et, rad2deg(it), rad2deg(Wt), rad2deg(wt), rad2deg(th1t), mu);
dv1 = norm(vt1-v1);

% Covering transfer leg
dt1 = flightTime(at, et, rad2deg(th1t), rad2deg(th2t));

% Evaluating second impulse
[~, vt2] = kep2car(at, et, rad2deg(it), rad2deg(Wt), rad2deg(wt), rad2deg(th2t), mu);
dv2 = norm(v2-vt2);

% Covering final leg
dt2 = flightTime(af, ef, rad2deg(thm2), rad2deg(thf));

% Final results
dv = dv1 + dv2;
dt = dt0 + dt1 + dt2;
th2t = rad2deg(th2t);
dth = rad2deg(dth);

end