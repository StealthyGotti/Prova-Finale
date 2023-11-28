% PROVA FINALE IAMS

%% DATA

mu = 398600;
fprintf('Keplerian elements reference: [a e i %c %c %c]\n', 937, 969, 952)

% Initial orbit
r0 = [-8205.9652; -4682.7991; 2382.4314];
v0 = [1.8330; -5.5360; -2.2630];
[kepEli(1), kepEli(2), kepEli(3), kepEli(4), kepEli(5), kepEli(6)] = car2kep(r0, v0, mu);
fprintf('Parametri kepleriani orbita iniziale: [%.2f %.4f %.2f %.2f %.2f %.2f]\n', kepEli(1), kepEli(2), kepEli(3), kepEli(4), kepEli(5), kepEli(6))
figure
hold on
grid on
xlabel('X [km]')
ylabel('Y [km]')
zlabel('Z [km]')
set(gca, 'FontSize', 12)
plotOrbit(kepEli, mu, .1, kepEli(6)+360, [0 0.4470 0.7410])
plot3(r0(1), r0(2), r0(3), 'o', 'MarkerSize', 10, 'MarkerEdgeColor', 'r', 'LineWidth', 3);

% Final orbit
kepElf = [11860.0000, 0.2614, rad2deg(0.5352), rad2deg(0.8005), rad2deg(2.3120), rad2deg(0.9719)];
fprintf('Parametri kepleriani orbita finale: [%.2f %.4f %.2f %.2f %.2f %.2f]\n', kepElf(1), kepElf(2), kepElf(3), kepElf(4), kepElf(5), kepElf(6))
plotOrbit(kepElf, mu, .1, kepElf(6)+360, [0.8500 0.3250 0.0980])
[rf, ~] = kep2car(kepElf(1), kepElf(2), kepElf(3), kepElf(4), kepElf(5), kepElf(6), mu);
plot3(rf(1), rf(2), rf(3), 'x', 'MarkerSize', 15, 'MarkerEdgeColor', 'r', 'LineWidth', 3);

% Perigees
[p1, ~] = kep2car(kepEli(1), kepEli(2), kepEli(3), kepEli(4), kepEli(5), 0, mu);
plot3(p1(1), p1(2), p1(3),  'k.', 'MarkerSize', 30)
[p2, ~] = kep2car(kepElf(1), kepElf(2), kepElf(3), kepElf(4), kepElf(5), 0, mu);
plot3(p2(1), p2(2), p2(3), 'k.', 'MarkerSize', 30)

% Equatorial Plane
[x, y] = meshgrid(-1.5*10000:50:1.5*10000, -10000*1.5:50:1.5*10000);
z = zeros(size(x));
surf(x, y, z, 'FaceAlpha', .75, 'EdgeColor', 'none', 'FaceColor', [.7 .7 .7]);
xlim([-1.5*10000 1.5*10000])
ylim([-1.5*10000 1.5*10000])
zlim([-1.5*10000 1.5*10000])
daspect([1 1 1])

% Info
% text(r0(1)+100, r0(2)+100, r0(3)+100, 'i', 'FontSize', 16, 'FontWeight', 'bold')
% text(rf(1)+100, rf(2)+100, rf(3)+100, 'f', 'FontSize', 16, 'FontWeight', 'bold')
legend('Initial Orbit', '', 'Initial Position', 'Final Orbit', '', 'Final position')
title('Overview')
view(30, 30)

%% MANOVRA STANDARD (PAF)

figure
hold on
grid on
xlabel('X [km]')
ylabel('Y [km]')
zlabel('Z [km]')
set(gca, 'FontSize', 12)
plot3(r0(1), r0(2), r0(3), 'o', 'MarkerSize', 10, 'MarkerEdgeColor', 'r', 'LineWidth', 3)
plot3(rf(1), rf(2), rf(3), 'x', 'MarkerSize', 15, 'MarkerEdgeColor', 'r', 'LineWidth', 3)

% Attesa fino al punto di manovra, cambio piano
[dv1, w1, th1, dt1] = changeOrbPlane (kepEli(1), kepEli(2), kepEli(3), kepEli(4), kepEli(5), kepElf(3), kepElf(4), kepEli(6));
plotOrbitQuiver(kepEli, mu, 10, th1)

% Attesa fino al punto di manovra, cambio di anomalia del pericentro
[dv2, th2, th3, dt2] = changePerArg (kepEli(1), kepEli(2), w1 , kepElf(5) , th1);
plotOrbitQuiver([kepEli(1) kepEli(2) kepElf(3) kepElf(4) w1 th1], mu, 10, th2)

% Attesa fino al punto di manovra di cambio di forma dell'orbita
dt23 = flightTime( kepEli(1) , kepEli(2) , th3 , 180); % tempo per arrivare all'apogeo
plotOrbitQuiver([kepEli(1) kepEli(2) kepElf(3) kepElf(4) kepElf(5) th3], mu, 10, 180)

% Manovra bitangente all'apogeo, cambio di forma dell'orbita
[dvi, dvf, thf, dt3, at, et] = biTangent (kepEli(1) , kepEli(2), kepElf(1) , kepElf(2), 180);
dv3 = dvi + dvf;
plotOrbitQuiver([at et kepElf(3) kepElf(4) kepElf(5) 180], mu, 10, 0)

% Attesa fino al punto finale
plotOrbitQuiver([kepElf(1) kepElf(2) kepElf(3) kepElf(4) kepElf(5) 0], mu, 10, kepElf(6))

% Tiro delle somme
dvstd = dv1 + dv2 + dv3;
fprintf('%cv complessivo procedura standard: %.2f km/s\n', 916, dvstd)
dtstd = dt1 + dt2 + dt23 + dt3;
[h, m, s] = time2esa(dtstd);
fprintf('%ct complessivo procedura standard: %.0f s = %.0f hr %.0f min %.0f s\n', 916, dtstd, h, m, s)

% Tutte le manovre sono eseguite alla prima posizione utile

Terra3d
xlim([-1.5*10000 1.5*10000])
ylim([-1.5*10000 1.5*10000])
zlim([-1.5*10000 1.5*10000])

legend('Init Pos', 'Fin Pos', 'Orb Init', 'Plane Changed', 'Periapsis Arg Changed', 'Shape Changed', 'Orb Fin')
title('Standard procedure')

%% ALTRE MANOVRE

%% MANOVRA BIELLITTICA

% Si procede con un'analisi della convenienza al variare del raggio di apocentro della biellittica

% non-skip trials
rbmin = 7000;
rbmax = 100000;
dvb = zeros(1,length(rbmin:100:rbmax));
dtb = zeros(1,length(rbmin:100:rbmax));
j = 1;
for rb = rbmin : 100 : rbmax
    [dv, dt] = biEllipticChangeOrb (kepEli, kepElf, rb);
    dvb(j) = dv;
    dtb(j) = dt;
    j = j+1;
end
rb = rbmin : 100 : rbmax;
figure
set(gca, 'FontSize', 12)
plot(rb, dvb, LineWidth=1)
xlabel('rb [km]')
ylabel('dv [km/s]')
title('Velocity (no skip)')
grid on
figure
set(gca, 'FontSize', 12)
plot(rb, dtb/3600, LineWidth=1)
xlabel('rb [km]')
ylabel('dt [hr]')
title('Time (no skip)')
grid on
dvbest = min(dvb);
pos = find(dvb==dvbest);
rbbest = rb(pos);
reltime = dtb(pos);
[h, m, s] = time2esa (reltime);
fprintf('Situazione più conveniente al primo punto di manovra biellittica disponibile:\nrb = %d km | %cv = %.2f km/s | %ct = %d h %d m %.0f s\n', rbbest, 916, dvbest, 916, h, m, s)

% Skip trials
j = 1;
for rb = rbmin : 100 : rbmax
    [dv, dt] = biEllipticChangeOrb (kepEli, kepElf, rb, 'skip');
    dvb(j) = dv;
    dtb(j) = dt;
    j = j+1;
end
rb = rbmin : 100 : rbmax;
figure
set(gca, 'FontSize', 12)
plot(rb, dvb, LineWidth=1)
xlabel('rb [km]')
ylabel('dv [km/s]')
title('Velocity (skip)')
grid on
figure
set(gca, 'FontSize', 12)
plot(rb, dtb/3600, LineWidth=1)
xlabel('rb [km]')
ylabel('dt [hr]')
title('Time (skip)')
grid on
dvbest = min(dvb);
pos = find(dvb==dvbest);
rbbest = rb(pos);
reltime = dtb(pos);
[h, m, s] = time2esa (reltime);
fprintf('Situazione più conveniente al secondo punto di manovra biellittica disponibile:\nrb = %d km | %cv = %.2f km/s | %ct = %d h %d m %.0f s\n', rbbest, 916, dvbest, 916, h, m, s)

% Rappresentazione manovra più conveniente in assoluto
figure
hold on
grid on
xlabel('X [km]')
ylabel('Y [km]')
zlabel('Z [km]')
set(gca, 'FontSize', 12)
plot3(r0(1), r0(2), r0(3), 'o', 'MarkerSize', 10, 'MarkerEdgeColor', 'r', 'LineWidth', 3)
plot3(rf(1), rf(2), rf(3), 'x', 'MarkerSize', 15, 'MarkerEdgeColor', 'r', 'LineWidth', 3)
pbaspect([1 1 1])
daspect([1 1 1])
[dvbi, dtbi, kepElt1, kepElt2, thm, thfb, axis] = biEllipticChangeOrb (kepEli, kepElf, 14000, 'skip');
plotOrbitQuiver(kepEli, mu, 5, thm)
plotOrbitQuiver([kepElt1(1) kepElt1(2) kepElt1(3) kepElt1(4) kepElt1(5) 0], mu, 5, 180) 
plotOrbitQuiver([kepElt2(1) kepElt2(2) kepElt2(3) kepElt2(4) kepElt2(5) 180], mu, 5, 360)
plotOrbitQuiver([kepElf(1) kepElf(2) kepElf(3) kepElf(4) kepElf(5) thfb], mu, 5, kepElf(6))
% plotOrbit(kepEli, mu, .1)
% plotOrbit(kepElt1, mu, .1)
% plotOrbit(kepElt2, mu, .1)
% plotOrbit(kepElf, mu, .1)
plot3(1e4*[-axis(1) axis(1)], 1e4*[-axis(2) axis(2)], 1e4*[-axis(3) axis(3)], 'k--')
Terra3d

legend('Init Pos', 'Fin Pos', 'Orb Init', 'First Arch', 'Second Arch', 'Orb Fin', 'Man Axis')
title('Bielliptic strategy')

% DA VERIFICARE MEGLIO (OCCHIO)
% valore minimo senza skip (prima manovra disponibile): 2.02 km/s @ 9300 km
% valore minimo con skip (seconda manovra disponibile): 1.75 km/s @ 14000 km

%% MANOVRA DIRETTA

figure
hold on
grid on
xlabel('X [km]')
ylabel('Y [km]')
zlabel('Z [km]')
set(gca, 'FontSize', 12)
plot3(r0(1), r0(2), r0(3), 'o', 'MarkerSize', 10, 'MarkerEdgeColor', 'r', 'LineWidth', 3)
plot3(rf(1), rf(2), rf(3), 'x', 'MarkerSize', 15, 'MarkerEdgeColor', 'r', 'LineWidth', 3)
pbaspect([1 1 1])
daspect([1 1 1])

% ESEMPIO
thm1 = 115.12; % da quale anomalia dell'orbita iniziale si vuole partire (default = kepEli(6), pos init)
thm2 = 158.61; % a quale anomalia vera dell'orbita finale si vuole arrivare (default = kepElf(6), pos fin)
et = 0.2183; % quale eccentricità si vuole che l'orbita di trasferimento abbia
[dvdir, dtdir, kepElt, th2t, dth, r1, r2, d1, d2, pt, v1, vt1, vt2, v2, dt0, dt1, dt2] = directOrb (kepEli, kepElf, et, thm1, thm2);

%[dv, dt, kepElt, th2t] = directOrb (kepEli, kepElf, kepEli(6), kepElf(6), 0);
%plotOrbit(kepEli, mu, .1)
%plotOrbit(kepElt, mu, .1)
%plotOrbit(kepElf, mu, .1)
plotOrbitQuiver(kepEli, mu, 5, thm1)
plotOrbitQuiver(kepElt, mu, 5, th2t)
plotOrbitQuiver([kepElf(1) kepElf(2) kepElf(3) kepElf(4) kepElf(5) thm2], mu, 5, kepElf(6))

% Info su velocità
quiver3(r1(1),r1(2),r1(3),1e3*v1(1),1e3*v1(2),1e3*v1(3))
quiver3(r1(1),r1(2),r1(3),1e3*vt1(1),1e3*vt1(2),1e3*vt1(3))
quiver3(r2(1),r2(2),r2(3),1e3*vt2(1),1e3*vt2(2),1e3*vt2(3))
quiver3(r2(1),r2(2),r2(3),1e3*v2(1),1e3*v2(2),1e3*v2(3))

Terra3d
legend('Init Pos', 'Fin Pos', 'Orb Init', 'Orb Trans', 'Orb Fin', '1e3*v1', '1e3*vt1', '1e3*vt2', '1e3*v2')
title('Direct transfer')

[h, m, s] = time2esa (dtdir);
fprintf('%cv complessivo manovra diretta: %.2f km/s\n', 916, dvdir)
fprintf('%ct complessivo manovra diretta: %.0f s = %.0f hr %.0f min %.0f s\n', 916, dtdir, h, m, s)

%% Trials on chosen combination

dvdirvect = zeros(length(0.01:0.01:0.99), 1);
dtdirvect = zeros(length(0.01:0.01:0.99), 1);
for et = 0.01:0.01:0.99
    [dvdir, dtdir] = directOrb (kepEli, kepElf, et, thm1, thm2);
    dvdirvect(round(100*et)) = dvdir;
    dtdirvect(round(100*et)) = dtdir;
end
et = 0.01:0.01:0.99;

figure
hold on
grid on
xlabel('eccentricity')
ylabel('dv [km/s] | dt [min]')
set(gca, 'FontSize', 12)
if mean(dtdirvect) < 60
    plot(et(~isnan(dtdirvect)), dvdirvect(~isnan(dtdirvect)), et(~isnan(dtdirvect)), dtdirvect(~isnan(dtdirvect))/60, LineWidth=1)
    legend('impulse [km/s]', 'time [min]')
else
    plot(et(~isnan(dtdirvect)), dvdirvect(~isnan(dtdirvect)), et(~isnan(dtdirvect)), dtdirvect(~isnan(dtdirvect))/3600, LineWidth=1)
    legend('impulse [km/s]', 'time [hr]')
end
title(sprintf('Direct transfer analysis (%.2f° to %.2f°)', thm1, thm2))

%% Absolute minimums reasearch

% velocity-oriented min research
ftarget = @(x) dirOrbv(kepEli, kepElf, x(1), x(2), x(3), 'off');
x0 = [0.2, 120, 150];
lb = [0.0001, 0, 0];
ub = [0.9999, 360, 360];
[xvmin, dvmin] = fminsearchbnd(ftarget, x0, lb, ub);
dtv = dirOrbt(kepEli, kepElf, xvmin(1), xvmin(2), xvmin(3), 'off');
[hv, mv, sv] = time2esa(dtv);
fprintf('Absolute minimum possible impulse value: %cv = %.2f km/s @ [%c1 = %.2f°, %c2 = %.2f°, e = %.4f, %ct = %.0f s (%.0f hr %.0f min %.0f s)]\n', 916, dvmin, 952, xvmin(2), 952, xvmin(3), xvmin(1), 916, dtv, hv, mv, sv)
figure
hold on
grid on
xlabel('X [km]')
ylabel('Y [km]')
zlabel('Z [km]')
set(gca, 'FontSize', 12)
plot3(r0(1), r0(2), r0(3), 'o', 'MarkerSize', 10, 'MarkerEdgeColor', 'r', 'LineWidth', 3)
plot3(rf(1), rf(2), rf(3), 'x', 'MarkerSize', 15, 'MarkerEdgeColor', 'r', 'LineWidth', 3)
pbaspect([1 1 1])
daspect([1 1 1])
thm1 = xvmin(2);
thm2 = xvmin(3);
et = xvmin(1);
[~, ~, kepElt, th2t, ~, r1, r2, ~, ~, ~, v1, vt1, vt2, v2] = directOrb (kepEli, kepElf, et, thm1, thm2);
%[dv, dt, kepElt, th2t] = directOrb (kepEli, kepElf, kepEli(6), kepElf(6), 0);
%plotOrbit(kepEli, mu, .1)
%plotOrbit(kepElt, mu, .1)
%plotOrbit(kepElf, mu, .1)
plotOrbitQuiver(kepEli, mu, 5, thm1)
plotOrbitQuiver(kepElt, mu, 5, th2t)
plotOrbitQuiver([kepElf(1) kepElf(2) kepElf(3) kepElf(4) kepElf(5) thm2], mu, 5, kepElf(6))
% Info su velocità
quiver3(r1(1),r1(2),r1(3),1e3*v1(1),1e3*v1(2),1e3*v1(3))
quiver3(r1(1),r1(2),r1(3),1e3*vt1(1),1e3*vt1(2),1e3*vt1(3))
quiver3(r2(1),r2(2),r2(3),1e3*vt2(1),1e3*vt2(2),1e3*vt2(3))
quiver3(r2(1),r2(2),r2(3),1e3*v2(1),1e3*v2(2),1e3*v2(3))
Terra3d
legend('Init Pos', 'Fin Pos', 'Orb Init', 'Orb Trans', 'Orb Fin', '1e3*v1', '1e3*vt1', '1e3*vt2', '1e3*v2')
title('Most impulse-convenient direct transfer')
view(30,30)

% velocity-oriented min research
ftarget = @(x) dirOrbt(kepEli, kepElf, x(1), x(2), x(3), 'off');
x0 = [0.7, 110, 50];
lb = [0.0001, 0, 0];
ub = [0.9999, 360, 360];
[xtmin, dtmin] = fminsearchbnd(ftarget, x0, lb, ub);
[ht, mt, st] = time2esa(dtmin);
fprintf('Absolute minimum possible flight time value: %ct = %.0f s (%.0f hr %.0f min %.0f s) @ [%c1 = %.2f°, %c2 = %.2f°, e = %.4f, %cv = %.2f km/s]\n', 916, dtmin, ht, mt, st, 952, xtmin(2), 952, xtmin(3), xtmin(1), 916, dirOrbv(kepEli, kepElf, xtmin(1), xtmin(2), xtmin(3), 'off'))
figure
hold on
grid on
xlabel('X [km]')
ylabel('Y [km]')
zlabel('Z [km]')
set(gca, 'FontSize', 12)
plot3(r0(1), r0(2), r0(3), 'o', 'MarkerSize', 10, 'MarkerEdgeColor', 'r', 'LineWidth', 3)
plot3(rf(1), rf(2), rf(3), 'x', 'MarkerSize', 15, 'MarkerEdgeColor', 'r', 'LineWidth', 3)
pbaspect([1 1 1])
daspect([1 1 1])
thm1 = xtmin(2);
thm2 = xtmin(3);
et = xtmin(1);
[~, ~, kepElt, th2t, ~, r1, r2, ~, ~, ~, v1, vt1, vt2, v2] = directOrb (kepEli, kepElf, et, thm1, thm2);
%[dv, dt, kepElt, th2t] = directOrb (kepEli, kepElf, kepEli(6), kepElf(6), 0);
%plotOrbit(kepEli, mu, .1)
%plotOrbit(kepElt, mu, .1)
%plotOrbit(kepElf, mu, .1)
plotOrbitQuiver(kepEli, mu, 5, thm1)
plotOrbitQuiver(kepElt, mu, 5, th2t)
plotOrbitQuiver([kepElf(1) kepElf(2) kepElf(3) kepElf(4) kepElf(5) thm2], mu, 5, kepElf(6))
% Info su velocità
quiver3(r1(1),r1(2),r1(3),1e3*v1(1),1e3*v1(2),1e3*v1(3))
quiver3(r1(1),r1(2),r1(3),1e3*vt1(1),1e3*vt1(2),1e3*vt1(3))
quiver3(r2(1),r2(2),r2(3),1e3*vt2(1),1e3*vt2(2),1e3*vt2(3))
quiver3(r2(1),r2(2),r2(3),1e3*v2(1),1e3*v2(2),1e3*v2(3))
Terra3d
legend('Init Pos', 'Fin Pos', 'Orb Init', 'Orb Trans', 'Orb Fin', '1e3*v1', '1e3*vt1', '1e3*vt2', '1e3*v2')
title('Most time-convenient direct transfer')
view(30,30)