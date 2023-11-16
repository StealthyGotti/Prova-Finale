function [dvi, dvf, thf, dt] = biTangent (ai, ei, af, ef, thm)

thm = deg2rad(thm);

mu = 398600;

if thm == 0
    r1 = ai*(1-ei);
    r2 = af*(1+ef);
    thf = pi;
elseif thm == pi
    r1 = ai*(1+ei);
    r2 = af*(1-ef);
    thf = 0;
else
    error('Only enter absidal points as maneuvering anomaly')
end

at = (r1+r2)/2;

dvi = abs(sqrt(2*mu*(1/r1-1/(2*at))) - sqrt(2*mu*(1/r1-1/(2*ai))));
dvf = abs(sqrt(2*mu*(1/r2-1/(2*af))) - sqrt(2*mu*(1/r2-1/(2*at))));

dt = pi*sqrt(at^3/mu);

thf = rad2deg(thf);

end