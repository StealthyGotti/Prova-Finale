function plotOrbitQuiver(kepEl, mu, n, thf, color)

a = kepEl(1);
e = kepEl(2);
i = kepEl(3);
OM = kepEl(4);
om = kepEl(5);
th0 = kepEl(6);

if nargin == 3
    thf = kepEl(6) + 360;
end

%[r0, ~] = kep2car (a, e, i, OM, om, th0, mu);
%[r0, ~] = kep2car (a, e, i, OM, om, thf, mu);

if thf >= th0
    th = linspace(th0,thf,n);
else
    th = linspace(th0,thf+360,n);
end

r = zeros(3, length(th));

for j = 1 : length(th)
    [r(:,j), ~] = kep2car (a, e, i, OM, om, th(j), mu);
end

X = r(1, :);
Y = r(2, :);
Z = r(3, :);

U = diff(X);
V = diff(Y);
W = diff(Z);

if nargin == 5
    quiver3(X(1:end-1), Y(1:end-1), Z(1:end-1), U, V, W, 0, 'LineWidth', 2, 'Color', color)
else
    quiver3(X(1:end-1), Y(1:end-1), Z(1:end-1), U, V, W, 0, 'LineWidth', 2)
end

%plot3(r0(1), r0(2), r0(3),'xr', 'LineWidth', 1)
%plot3(rf(1), rf(2), rf(3),'xr', 'LineWidth', 1)

end