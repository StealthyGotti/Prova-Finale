function [dvi, dvf, thf, dt, at, et] = biTangent (ai, ei, af, ef, thm, turnaround)

if nargin == 5
    turnaround = 'off';
end

thm = deg2rad(thm);

mu = 398600;

if thm == 0 && strcmp(turnaround, 'off')
    r1 = ai*(1-ei);
    r2 = af*(1+ef);
    thf = pi;
elseif thm == pi && strcmp(turnaround, 'off')
    r1 = ai*(1+ei);
    r2 = af*(1-ef);
    thf = 0;
elseif thm == 0 && strcmp(turnaround, 'on')
    r1 = ai*(1-ei);
    r2 = af*(1-ef);
    thf = 0;
elseif thm == pi && strcmp(turnaround, 'on')
    r1 = ai*(1+ei);
    r2 = af*(1+ef);
    thf = pi;
else
    error('Only enter absidal points as maneuvering anomaly, or valid turnaround value: ''on'' or ''off''')
end

at = (r1+r2)/2;
et = abs(r2-r1)/(r2+r1);

dvi = abs(sqrt(2*mu*(1/r1-1/(2*at))) - sqrt(2*mu*(1/r1-1/(2*ai))));
dvf = abs(sqrt(2*mu*(1/r2-1/(2*af))) - sqrt(2*mu*(1/r2-1/(2*at))));

dt = pi*sqrt(at^3/mu);

thf = rad2deg(thf);

end