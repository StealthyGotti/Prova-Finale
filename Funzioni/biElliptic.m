function [dv1, dv2, dv3, thf, dt] = biElliptic (ai, ei, af, ef, rb, thm)

mu = 398600;

if thm == 0
    r1 = ai*(1-ei);
    r2 = rb;
    r3 = af*(1-ef);
    thf = 0;
elseif thm == pi
    r1 = ai*(1+ei);
    r2 = rb;
    r3 = af*(1+ef);
    thf = pi;
else
    error('Inserire solo punti absidali come anomalia di manovra')
end

at1 = (r1+r2)/2;
at2 = (r2+r3)/2;

dv1 = abs(sqrt(2*mu*(1/r1-1/2*at1)) - sqrt(2*mu*(1/r1-1/2*ai)));
dv2 = abs(sqrt(2*mu*(1/r1-1/2*at2)) - sqrt(2*mu*(1/r1-1/2*at1)));
dv3 = abs(sqrt(2*mu*(1/r2-1/2*af)) - sqrt(2*mu*(1/r2-1/2*at2)));

dt1 = pi*sqrt(at1^3/mu);
dt2 = pi*sqrt(at2^3/mu);

dt = dt1 + dt2;

end