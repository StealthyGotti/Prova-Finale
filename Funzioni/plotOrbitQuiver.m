function plotOrbitQuiver(kepEl, mu, stepTh, thf, color)

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
    th = th0:stepTh:thf;
    th(end) = thf;
else
    th = th0:stepTh:thf+360;
    th(end) = thf+360;
end

r = zeros(3, length(th));

for j = 1 : length(th)
    [r(:,j), ~] = kep2car (a, e, i, OM, om, th(j), mu);
end

if abs(thf-th0) < stepTh
    X = [0 0];
    Y = [0 0];
    Z = [0 0];
    
    U = diff(X);
    V = diff(Y);
    W = diff(Z);
else
    X = r(1, :);
    Y = r(2, :);
    Z = r(3, :);
    
    U = diff(X);
    V = diff(Y);
    W = diff(Z);
end

if nargin == 5
    quiver3(X(1:end-1), Y(1:end-1), Z(1:end-1), U, V, W, 0, 'LineWidth', 2, 'MaxHeadSize', .1, 'AutoScale', 'off', 'AutoScaleFactor', 100, 'Color', color)
else
    quiver3(X(1:end-1), Y(1:end-1), Z(1:end-1), U, V, W, 0, 'LineWidth', 2, 'MaxHeadSize', .1, 'AutoScale', 'off', 'AutoScaleFactor', 100)
end

%plot3(r0(1), r0(2), r0(3),'xr', 'LineWidth', 1)
%plot3(rf(1), rf(2), rf(3),'xr', 'LineWidth', 1)

end