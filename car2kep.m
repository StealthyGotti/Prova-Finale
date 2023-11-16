function [a, e, i, OM, om, th] = car2kep (r, v, mu)

I = [1; 0; 0];
% J = [0; 1; 0];
K = [0; 0; 1];

h = cross(r, v);
E = dot(v,v)/2 - mu/norm(r);

a = -mu/(2*E);
evect = cross(v, h)/mu - r/norm(r);
e = norm(evect);
i = acos(dot(K, h)/norm(h));

if cross(K, h) == 0
    N = [1; 0; 0];
else
    N = (cross(K, h))/norm(cross(K, h));
end

if N(2) >= 0
    OM = acos((dot(I, N))/norm(N));
elseif N(2) < 0
    OM = 2*pi - acos((dot(I, N))/norm(N));
end

if evect(3) >= 0
    om = acos((dot(evect, N))/(e*norm(N)));
elseif evect(3) < 0
    om = 2*pi - acos((dot(evect, N))/(e*norm(N)));
end

vrad = dot(r, v);

if vrad >= 0
    th = acos(dot(evect, r)/(e*norm(r)));
elseif vrad < 0
    th = 2*pi - acos(dot(evect, r)/(e*norm(r)));
end

i = rad2deg(i);
OM = rad2deg(OM);
om = rad2deg(om);
th = rad2deg(th);

end