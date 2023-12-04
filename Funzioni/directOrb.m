function [dv, dt, kepElt, th2t, dth, r1, r2, d1, d2, pt, v1, vt1, dv1, vt2, v2, dv2, dt0, dt1, dt2, thc1t, thc2t] = directOrb (kepEli, kepElf, et, thm1, thm2, option, warnings)

mu = 398600;
Rt = 6378;
sh = Rt + 100; % safety height

% Rapid use
if nargin == 3
    thm1 = kepEli(6);
    thm2 = kepElf(6);
    warnings = 'off';
    option = 'best';
end
if nargin == 5
    option = 'best';
    warnings = 'off';
end
if nargin == 6
    warnings = 'off';
end

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
    if et ~= 0 && abs(d1-d2) < 1e-6 && strcmp(warnings,'on')
        warning('Eccentricity could be set to 0 as selected maneuvering distances are equal to each other for %c1 = %.2f°, %c2 = %.2f°, e = %.4f', 952, rad2deg(thm1), 952, rad2deg(thm2), et)
    end
    fun = @(x) d2*(1 + et*cos(x+dth)) - d1*(1 + et*cos(x));
    if dth < pi && strcmp(option, 'per')
        x0 = 0;
    elseif dth < pi && strcmp(option, 'apo')
        x0 = pi;
    elseif dth >= pi && strcmp(option, 'per')
        x0 = pi;
    elseif dth >= pi && strcmp(option, 'apo')
        x0 = 0;
    elseif strcmp(option, 'best')
        x0 = [0 pi];
    end
    sol = fsolve(fun, x0, optimset('Display', 'off'));
    sol = unique(sol(abs(fun(sol)) < 1e-6));
    if isempty(sol) % returning NaN values if no solution is found
        dv = NaN;
        dt = NaN;
        kepElt = [NaN NaN NaN NaN NaN NaN];
        dth = rad2deg(dth);
        th2t = NaN;
        pt = NaN; 
        v1 = NaN; 
        vt1 = NaN;
        dv1 = NaN;
        vt2 = NaN;
        v2 = NaN;
        dv2 = NaN;
        dt0 = NaN; 
        dt1 = NaN; 
        dt2 = NaN;
        thc1t = NaN;
        thc2t = NaN;
        if strcmp(warnings,'on')
            warning('Couldn''t find a solution for %c1 = %.2f°, %c2 = %.2f°, e = %.4f', 952, rad2deg(thm1), 952, rad2deg(thm2), et)
        end
        return
    end
    th1t = mod(sol, 2*pi);
    th2t = mod(th1t+dth, 2*pi);
    pt = d1*(1+et*cos(th1t));
    % Earth collision safety check
    thc1t = acos((pt/sh-1)/et);
    thc2t = 2*pi - thc1t;
    if all(imag(thc1t)~=0) % no possible collision
        if strcmp(option, 'best') && ~isscalar(sol) % no orbit can be ruled out a priori
            ambiguity = true;
        else
            thc1t = NaN;
            thc2t = NaN;
            ambiguity = false;
        end
    else % possible collision
        if strcmp(option, 'best') && ~isscalar(sol)
            c = find(thc1t==real(thc1t));
            if isscalar(c)
                if ((th2t(c) >= th1t(c)) && ((th1t(c) >= 0 && th1t(c) <= thc1t(c)) || (th2t(c) >= thc2t(c) && th2t(c) <= 2*pi))) || (th2t(c) < th1t(c))
                    if c == 1
                        th1t = th1t(2);
                        th2t = th2t(2);
                        pt = pt(2);
                        thc1t = NaN;
                        thc2t = NaN;
                        ambiguity = false;
                    elseif c == 2
                        th1t = th1t(1);
                        th2t = th2t(1);
                        pt = pt(1);
                        thc1t = NaN;
                        thc2t = NaN;
                        ambiguity = false;
                    end
                else % no orbit can be ruled out a priori
                    ambiguity = true;
                end
            else
                if (((th2t(1) >= th1t(1)) && ((th1t(1) >= 0 && th1t(1) <= thc1t(1)) ||(th2t(1) >= thc2t(1) && th2t(1) <= 2*pi))) || (th2t(1) < th1t(1))) && (((th2t(2) >= th1t(2)) && ((th1t(2) >= 0 && th1t(2) <= thc1t(2)) ||(th2t(2) >= thc2t(2) && th2t(2) <= 2*pi))) || (th2t(2) < th1t(2)))
                    dv = NaN;
                    dt = NaN;
                    kepElt = [NaN NaN NaN NaN NaN NaN];
                    dth = rad2deg(dth);
                    th2t = NaN;
                    pt = NaN; 
                    v1 = NaN; 
                    vt1 = NaN;
                    dv1 = NaN;
                    vt2 = NaN; 
                    v2 = NaN;
                    dv2 = NaN;
                    dt0 = NaN; 
                    dt1 = NaN; 
                    dt2 = NaN;
                    if strcmp(warnings,'on')
                        warning('Couldn''t find a non-colliding solution for %c1 = %.2f°, %c2 = %.2f°, e = %.4f', 952, rad2deg(thm1), 952, rad2deg(thm2), et)
                    end
                    return
                elseif ((th2t(1) >= th1t(1)) && ((th1t(1) >= 0 && th1t(1) <= thc1t(1)) ||(th2t(1) >= thc2t(1) && th2t(1) <= 2*pi))) || (th2t(1) < th1t(1))
                    th1t = th1t(2);
                    th2t = th2t(2);
                    thc1t = thc1t(2);
                    thc2t = thc2t(2);
                    pt = pt(2);
                    ambiguity = false;
                    if strcmp(warnings,'on')     
                        warning('Possible Earth collision in case of failed maneuver for %c1 = %.2f°, %c2 = %.2f°, e = %.4f', 952, rad2deg(thm1), 952, rad2deg(thm2), et)
                    end
                elseif ((th2t(2) >= th1t(2)) && ((th1t(2) >= 0 && th1t(2) <= thc1t(2)) ||(th2t(2) >= thc2t(2) && th2t(2) <= 2*pi))) || (th2t(2) < th1t(2))
                    th1t = th1t(1);
                    th2t = th2t(1);
                    thc1t = thc1t(1);
                    thc2t = thc2t(1);
                    pt = pt(1);
                    ambiguity = false;
                    if strcmp(warnings,'on')      
                        warning('Possible Earth collision in case of failed maneuver for %c1 = %.2f°, %c2 = %.2f°, e = %.4f', 952, rad2deg(thm1), 952, rad2deg(thm2), et)
                    end
                else % no orbit can be ruled out a priori
                    ambiguity = true;
                end
            end
        else % specific orbit requested or single solution found
            if (th2t >= th1t) && (th1t > thc1t && th2t < thc2t)
                if strcmp(warnings,'on') 
                    warning('Possible Earth collision in case of failed maneuver for %c1 = %.2f°, %c2 = %.2f°, e = %.4f', 952, rad2deg(thm1), 952, rad2deg(thm2), et)
                end
            elseif ((th2t >= th1t) && ((th1t >= 0 && th1t <= thc1t) ||(th2t >= thc2t && th2t <= 2*pi))) || (th2t < th1t)
                if strcmp(warnings,'on')     
                    warning('Earth collision for %c1 = %.2f°, %c2 = %.2f°, e = %.4f', 952, rad2deg(thm1), 952, rad2deg(thm2), et)
                end
            end
            ambiguity = false;
        end        
    end
    I = [1; 0; 0];
    K = [0; 0; 1];
    if ambiguity
        % Initializing combinations of variables
        kepElt = zeros(2, 6);
        vt1 = zeros(3, 2);
        dv1 = zeros(1, 2);
        vt2 = zeros(3, 2);
        dv2 = zeros(1, 2);
        dt1 = zeros(1, 2);
        at = zeros(1, 2);
        it = zeros(1, 2);
        Wt = zeros(1, 2);
        wt = zeros(1, 2);
        for t = 1 : 2
            ht = sqrt(pt(t)*mu);
            ht = ht*k;
            it(t) = acos(dot(K, ht)/norm(ht));
            if cross(K, ht) == 0
                Nt = [1; 0; 0];
            else
                Nt = (cross(K, ht))/norm(cross(K, ht));
            end
            if Nt(2) >= 0
                Wt(t) = acos((dot(I, Nt))/norm(Nt));
            elseif Nt(2) < 0
                Wt(t) = 2*pi - acos((dot(I, Nt))/norm(Nt));
            end
            at(t) = pt(t)/(1-norm(et)^2);
            et = norm(et)*(i*cos(th1t(t))-j*sin(th1t(t)));
            if et(3) >= 0
                wt(t) = acos((dot(et, Nt))/(norm(et)*norm(Nt)));
            elseif et(3) < 0
                wt(t) = 2*pi - acos((dot(et, Nt))/(norm(et)*norm(Nt)));
            end
            kepElt(t, :) = [at(t), norm(et), rad2deg(it(t)), rad2deg(Wt(t)), rad2deg(wt(t)), rad2deg(th1t(t))];
        end
    else
        ht = sqrt(pt*mu);
        ht = ht*k;
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
        kepElt = [at, norm(et), rad2deg(it), rad2deg(Wt), rad2deg(wt), rad2deg(th1t)];
    end
elseif et == 0 && abs(d1-d2) >= 1e-6 % rejecting circular solution
    dv = NaN;
    dt = NaN;
    kepElt = [NaN NaN NaN NaN NaN NaN];
    dth = rad2deg(dth);
    th2t = NaN;  
    pt = NaN; 
    v1 = NaN; 
    vt1 = NaN;
    dv1 = NaN;
    vt2 = NaN; 
    v2 = NaN;
    dv2 = NaN;
    dt0 = NaN; 
    dt1 = NaN; 
    dt2 = NaN;
    thc1t = NaN;
    thc2t = NaN;
    if strcmp(warnings,'on')
        warning('Couldn''t find a solution for %c1 = %.2f°, %c2 = %.2f°, e = %.4f', 952, rad2deg(thm1), 952, rad2deg(thm2), et)
    end
    return
elseif et == 0 && abs(d1-d2) < 1e-6 % accepting circular solution
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
    kepElt = [at, norm(et), rad2deg(it), rad2deg(Wt), rad2deg(wt), rad2deg(th1t)];
    ambiguity = false;
end

et = norm(et);

if ambiguity
    for t = 1 : 2
        % Evaluating first impulse
        [~, vt1(:, t)] = kep2car(at(t), et, rad2deg(it(t)), rad2deg(Wt(t)), rad2deg(wt(t)), rad2deg(th1t(t)), mu);
        dv1(t) = norm(vt1(:, t)-v1);
        % Covering transfer leg
        dt1(t) = flightTime(at(t), et, rad2deg(th1t(t)), rad2deg(th2t(t)));
        % Evaluating second impulse
        [~, vt2(:, t)] = kep2car(at(t), et, rad2deg(it(t)), rad2deg(Wt(t)), rad2deg(wt(t)), rad2deg(th2t(t)), mu);
        dv2(t) = norm(v2-vt2(:, t));
    end
        if (dv1(1)+dv2(1))<(dv1(2)+dv2(2)) && (dt1(1)<dt1(2)) % orbit 1 is chosen
            orb = 1;
        elseif (dv1(2)+dv2(2))<(dv1(1)+dv2(1)) && (dt1(2)<dt1(1)) % orbit 2 is chosen
            orb = 2;
        elseif ((dv1(1)+dv2(1))<(dv1(2)+dv2(2)) && (dt1(1)>dt1(2)))
            if ((dv1(1)+dv2(1))/(dv1(2)+dv2(2)) < dt1(2)/dt1(1)) % orbit 1 is chosen
                orb = 1;
            else % orbit 2 is chosen
                orb = 2;
            end
        elseif ((dv1(1)+dv2(1))>(dv1(2)+dv2(2)) && (dt1(1)<dt1(2)))
            if ((dv1(2)+dv2(2))/(dv1(1)+dv2(1)) < dt1(1)/dt1(2)) % orbit 2 is chosen
                orb = 2;
            else % orbit 1 is chosen
                orb = 1;
            end
        else % random orbit is chosen (practically impossible)
            orb = randi([1, 2]);
            if strcmp(warnings,'on')     
                warning('Random orbit was chosen for %c1 = %.2f°, %c2 = %.2f°, e = %.4f', 952, rad2deg(thm1), 952, rad2deg(thm2), et)
            end
        end

        if orb == 1
            kepElt = kepElt(1, :);
            th2t = th2t(1);
            pt = pt(1);
            vt1 = vt1(:, 1);
            vt2 = vt2(:, 1);
            dv1 = dv1(1);
            dv2 = dv2(1);
            dt1 = dt1(1);
            if isreal(thc1t(1))
                thc1t = thc1t(1);
                thc2t = thc2t(1);
            else
                thc1t = NaN;
                thc2t = NaN;
            end
        elseif orb == 2
            kepElt = kepElt(2, :);
            th2t = th2t(2);
            pt = pt(2);
            vt1 = vt1(:, 2);
            vt2 = vt2(:, 2);
            dv1 = dv1(2);
            dv2 = dv2(2);
            dt1 = dt1(2);
            if isreal(thc1t(2))
                thc1t = thc1t(2);
                thc2t = thc2t(2);
            else
                thc1t = NaN;
                thc2t = NaN;
            end
        end
else
    % Evaluating first impulse
    [~, vt1] = kep2car(at, et, rad2deg(it), rad2deg(Wt), rad2deg(wt), rad2deg(th1t), mu);
    dv1 = norm(vt1-v1);
    % Covering transfer leg
    dt1 = flightTime(at, et, rad2deg(th1t), rad2deg(th2t));
    % Evaluating second impulse
    [~, vt2] = kep2car(at, et, rad2deg(it), rad2deg(Wt), rad2deg(wt), rad2deg(th2t), mu);
    dv2 = norm(v2-vt2);
end

% Covering final leg
dt2 = flightTime(af, ef, rad2deg(thm2), rad2deg(thf));

% Final results
dv = dv1 + dv2;
dt = dt0 + dt1 + dt2;
th2t = rad2deg(th2t);
dth = rad2deg(dth);
thc1t = rad2deg(thc1t);
thc2t = rad2deg(thc2t);

end