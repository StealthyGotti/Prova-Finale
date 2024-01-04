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
Terra3d
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

% Table Compiling, Initial data
TableCompiler( kepEli , 0 , 0, 'Given initial data')
% Attesa fino al punto di manovra, cambio piano
[dv1, w1, th1, dt1] = changeOrbPlane (kepEli(1), kepEli(2), kepEli(3), kepEli(4), kepEli(5), kepElf(3), kepElf(4), kepEli(6));
plotOrbitQuiver(kepEli, mu, 10, th1)
% Table Compiling, plane change
TableCompiler( [kepEli(1:5) th1] , dv1 , dt1, 'Standard maneuver')
TableCompiler( [kepEli(1:2) kepElf(3:4) w1 th1], dv1 , dt1)

% Attesa fino al punto di manovra, cambio di anomalia del pericentro
[dv2, th2, th3, dt2] = changePerArg (kepEli(1), kepEli(2), w1 , kepElf(5) , th1);
plotOrbitQuiver([kepEli(1) kepEli(2) kepElf(3) kepElf(4) w1 th1], mu, 10, th2)
TableCompiler( [kepEli(1) kepEli(2) kepElf(3) kepElf(4) w1 th1] , dv2 ,dt1 + dt2 )
TableCompiler( [kepEli(1) kepEli(2) kepElf(3) kepElf(4) kepElf(5) th3] , dv2 , dt1 + dt2 )

% Attesa fino al punto di manovra di cambio di forma dell'orbita
dt23 = flightTime( kepEli(1) , kepEli(2) , th3 , 180); % tempo per arrivare all'apogeo
plotOrbitQuiver([kepEli(1) kepEli(2) kepElf(3) kepElf(4) kepElf(5) th3], mu, 10, 180)
TableCompiler( [kepEli(1) kepEli(2) kepElf(3) kepElf(4) kepElf(5) 180] , 0 , dt1+dt2+dt23 )

% Manovra bitangente all'apogeo, cambio di forma dell'orbita
[dvi, dvf, thf, dt3, at, et] = biTangent (kepEli(1) , kepEli(2), kepElf(1) , kepElf(2), 180);
dv3 = dvi + dvf;
plotOrbitQuiver([at et kepElf(3) kepElf(4) kepElf(5) 180], mu, 10, 0)
TableCompiler( [kepEli(1) kepEli(2) kepElf(3) kepElf(4) kepElf(5) 180] , dvi , dt1+dt2+dt23)
TableCompiler( [at et kepElf(3) kepElf(4) kepElf(5) thf] , dvi , dt1+dt2+dt23)
TableCompiler( [at et kepElf(3) kepElf(4) kepElf(5) thf] , dvf , dt1+dt2+dt23+dt3)
TableCompiler( [kepElf(1:5) thf] , dvf , dt1+dt2+dt23+dt3)

% Attesa fino al punto finale
dt34 = flightTime ( kepElf(1) , kepElf(2) , 0 , kepElf(6));
plotOrbitQuiver([kepElf(1) kepElf(2) kepElf(3) kepElf(4) kepElf(5) 0], mu, 10, kepElf(6))
TableCompiler( [kepElf(1:6)] , 0 , dt1+dt2+dt23+dt3+dt34)

% Tiro delle somme
dvstd = dv1 + dv2 + dv3;
fprintf('%cv complessivo procedura standard: %.2f km/s\n', 916, dvstd)
dtstd = dt1 + dt2 + dt23 + dt3 + dt34;
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
%% MANOVRA AF1P
clear;
close all;
clc;
mu = 398600;

% Orbita iniziale
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
%plotOrbit(kepEli, mu, .1)
plot3(r0(1), r0(2), r0(3), 'o', 'MarkerSize', 10, 'MarkerEdgeColor', 'r', 'LineWidth', 3)
hold on

% Orbita finale
kepElf = [11860.0000, 0.2614, rad2deg(0.5352), rad2deg(0.8005), rad2deg(2.3120), rad2deg(0.9719)];
fprintf('Parametri kepleriani orbita finale: [%.2f %.4f %.2f %.2f %.2f %.2f]\n', kepElf(1), kepElf(2), kepElf(3), kepElf(4), kepElf(5), kepElf(6))
%plotOrbit(kepElf, mu, .1)
hold on
[rf, ~] = kep2car(kepElf(1), kepElf(2), kepElf(3), kepElf(4), kepElf(5), kepElf(6), mu);
plot3(rf(1), rf(2), rf(3), 'x', 'MarkerSize', 15, 'MarkerEdgeColor', 'r', 'LineWidth', 3)

hold on

% % Perigei
% [p1, ~] = kep2car(kepEli(1), kepEli(2), kepEli(3), kepEli(4), kepEli(5), 0, mu);
% plot3(p1(1), p1(2), p1(3),  'k.', 'MarkerSize', 30);
% [p2, ~] = kep2car(kepElf(1), kepElf(2), kepElf(3), kepElf(4), kepElf(5), 0, mu);
% plot3(p2(1), p2(2), p2(3), 'k.', 'MarkerSize', 30);

% cambio anomalia -> cambio forma (1) -> cambio piano (causante un cambio di w)

% ALLINEAMENTO ASSI ECCENTRICITA'

a_i = kepEli(1);
e_i = kepEli(2); 
i_i = kepEli(3);
OM_i = kepEli(4); 
om_i = kepEli(5); 
th_i = kepEli(6);

a_f = 11860;
e_f = 0.2614; 
i_f = kepElf(3);
OM_f = kepElf(4); 
om_f = kepElf(5); 
theta_f = kepElf(6);

om_st = om_f - (144.12175 - om_f); % anomalia del perigeo "strategico", il quale permette di ottenere
...in seguito al cambio di piano (nel corrispettivo punto di manovra) l'anomalia di perigeo richiesta per l'orbita finale.

% Table Compiling, Initial data
TableCompiler( kepEli , 0 , 0, 'Given initial data')
% CAMBIO ANOMALIA
[dv_1, thm ,thf1, dt1 ] = changePerArg (a_i, e_i, om_i , om_st , th_i);
%[delta_T] = timeOfFlight (a_i,e_i,th_ir,thm);
TableCompiler( [kepEli(1:4) om_st thm] , dv_1 , dt1, 'AF1P maneuver')
TableCompiler( [kepEli(1:4) om_st thf1] , dv_1 , dt1, 'AF1P maneuver')

plotOrbitQuiver([a_i , e_i , i_i , OM_i , om_i , th_i ], mu, 5 , thm)  % tratto 1
hold on

plotOrbitQuiver([a_i , e_i , i_i , OM_i , om_st , thf1 ], mu, 5, 180)  % tratto 2
hold on

% Tempo di trasferimento dal punto di cambio anomalia all'apocentro
dt2 = flightTime (a_i, e_i, thf1, 180);
TableCompiler( [kepEli(1:4) om_st 180] , 0 , dt1+dt2, 0)

% CAMBIO FORMA (apocentro orbita iniziale -> pericentro orbita finale)
[dvi, dvf, th, dt3, a_t, e_t] = biTangent (a_i, e_i, a_f, e_f, 180);
dv_2 = dvi + dvf;
TableCompiler( [a_t e_t kepEli(3:4) om_st 0] , dvi , dt1+dt2+dt3, 0)
TableCompiler( [kepElf(1:2) kepEli(3:4) om_st 0] , dvf , dt1+dt2+dt3, 0)


plotOrbitQuiver([a_t , e_t , i_i , OM_i , om_st , 180 ], mu, 5 , 0)  % tratto 3

hold on

% CAMBIO PIANO
[dv_3, wf, thf, dt4] = changeOrbPlane (a_f, e_f, i_i, OM_i, om_st, i_f, OM_f, 0);

plotOrbitQuiver([a_f , e_f , i_i , OM_i , om_st , 0 ], mu, 5 , thf)  % tratto 4

plotOrbitQuiver([a_f , e_f , i_f , OM_f , wf , thf ], mu, 5 , theta_f)  % tratto 5
TableCompiler( [kepElf(1:4) wf thf] , dv_3 , dt1+dt2+dt3+dt4, 0)


hold on

% Tempo di trasferimento dal punto di cambio piano al punto di rilascio
dt5 = flightTime (a_f, e_f, thf, theta_f);
TableCompiler( [kepElf(1:6)] , 0 , dt1+dt2+dt3+dt4+dt5, 0)

Terra3d

xlim([-1.5*10000 1.5*10000])
ylim([-1.5*10000 1.5*10000])
zlim([-1.5*10000 1.5*10000])

legend('Init Pos', 'Fin Pos', 'Orb Init', 'Periapsis Arg Changed', 'Shape Changed' , 'Plane Changed' , 'Orb Fin')

title('AF1P procedure')

% COSTO TOTALE E TEMPO DI TRASFERIMENTO DELLA MISSIONE

dv_TOT = abs(dv_1) + abs(dv_2) + abs(dv_3);   % 2.1626 km/s
dt_TOT_sec = dt1 + dt2 + dt3 + dt4 + dt5; % 23189 sec = 6 hr 26 min 29 s
[h, m, s] = time2esa(dt_TOT_sec);

fprintf('%cv AF1P: %.2f km/s\n', 916, dv_TOT)
fprintf('%ct AF1P: %.0f s = %.0f hr %.0f min %.0f s\n', 916, dt_TOT_sec, h, m, s)

%% MANOVRA AF2P
clear;
close all;
clc;
mu = 398600;

% Orbita iniziale
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
%plotOrbit(kepEli, mu, .1)
plot3(r0(1), r0(2), r0(3), 'o', 'MarkerSize', 10, 'MarkerEdgeColor', 'r', 'LineWidth', 3)
hold on

% Table Compiling, Initial data
TableCompiler( kepEli , 0 , 0, 'Given initial data')

% Orbita finale
kepElf = [11860.0000, 0.2614, rad2deg(0.5352), rad2deg(0.8005), rad2deg(2.3120), rad2deg(0.9719)];
fprintf('Parametri kepleriani orbita finale: [%.2f %.4f %.2f %.2f %.2f %.2f]\n', kepElf(1), kepElf(2), kepElf(3), kepElf(4), kepElf(5), kepElf(6))
%plotOrbit(kepElf, mu, .1)
hold on
[rf, ~] = kep2car(kepElf(1), kepElf(2), kepElf(3), kepElf(4), kepElf(5), kepElf(6), mu);
plot3(rf(1), rf(2), rf(3), 'x', 'MarkerSize', 15, 'MarkerEdgeColor', 'r', 'LineWidth', 3)

hold on

% % Perigei
% [p1, ~] = kep2car(kepEli(1), kepEli(2), kepEli(3), kepEli(4), kepEli(5), 0, mu);
% plot3(p1(1), p1(2), p1(3),  'k.', 'MarkerSize', 30);
% [p2, ~] = kep2car(kepElf(1), kepElf(2), kepElf(3), kepElf(4), kepElf(5), 0, mu);
% plot3(p2(1), p2(2), p2(3), 'k.', 'MarkerSize', 30);

% cambio anomalia -> cambio forma (2)  -> cambio piano (causante un cambio di w)

% ALLINEAMENTO ASSI ECCENTRICITA'

a_i = kepEli(1);
e_i = kepEli(2); 
i_i = kepEli(3);
OM_i = kepEli(4); 
om_i = kepEli(5); 
th_i = kepEli(6);

a_f = 11860;
e_f = 0.2614; 
i_f = kepElf(3);
OM_f = kepElf(4); 
om_f = kepElf(5); 
theta_f = kepElf(6);

om_st = om_f - (144.12175 - om_f); % anomalia del perigeo "strategico", il quale permette di ottenere
...in seguito al cambio di piano (nel corrispettivo punto di manovra) l'anomalia di perigeo richiesta per l'orbita finale.

% CAMBIO ANOMALIA
[dv_1, thm ,thf1, dt1 ] = changePerArg (a_i, e_i, om_i , om_st , th_i);
%[delta_T] = timeOfFlight (a_i,e_i,th_ir,thm);
TableCompiler( [kepEli(1:5) thm] , dv_1 , dt1, 'AF2P maneuver')
TableCompiler( [kepEli(1:4) om_st thf1] , dv_1 , dt1, 0)

plotOrbitQuiver([a_i , e_i , i_i , OM_i , om_i , th_i ], mu, 5 , thm)  % tratto 1
hold on

plotOrbitQuiver([a_i , e_i , i_i , OM_i , om_st , thf1 ], mu, 5, 0)  % tratto 2
hold on

% Tempo di trasferimento dal punto di cambio anomalia al pericentro
dt2 = flightTime (a_i, e_i, thf1, 0);
TableCompiler( [kepEli(1:4) om_st 0], 0 , dt1+dt2, 0)

% CAMBIO FORMA (pericentro orbita iniziale -> apocentro orbita finale)
[dvi, dvf, th, dt3, a_t, e_t] = biTangent (a_i, e_i, a_f, e_f, 0);
dv_2 = dvi + dvf;
TableCompiler( [a_t e_t kepEli(3:4) om_st 0] , dvi , dt1+dt2+dt3, 0)
TableCompiler( [kepElf(1:2) kepEli(3:4) om_st 180] , dvf , dt1+dt2+dt3, 0)


plotOrbitQuiver([a_t , e_t , i_i , OM_i , om_st , 0 ], mu, 5 , 180)  % tratto 3

hold on

% CAMBIO PIANO
[dv_3, wf, thf, dt4] = changeOrbPlane (a_f, e_f, i_i, OM_i, om_st, i_f, OM_f, 180);
TableCompiler( [kepElf(1:4) wf thf] , dv_3 , dt1+dt2+dt3+dt4, 0)

plotOrbitQuiver([a_f , e_f , i_i , OM_i , om_st , 180 ], mu, 5 , thf)  % tratto 4
plotOrbitQuiver([a_f , e_f , i_f , OM_f , wf , thf ], mu, 5 , theta_f)  % tratto 5

hold on

% Tempo di trasferimento dal punto di cambio piano al punto di rilascio
dt5 = flightTime (a_f, e_f, thf, theta_f);
TableCompiler( kepElf , 0 , dt1+dt2+dt3+dt4+dt5 , 0)

Terra3d

xlim([-1.5*10000 1.5*10000])
ylim([-1.5*10000 1.5*10000])
zlim([-1.5*10000 1.5*10000])

legend('Init Pos', 'Fin Pos', 'Orb Init','', 'Periapsis Arg Changed','', 'Shape Changed' ,'', 'Plane Changed' ,'', 'Orb Fin')

title('AF2P procedure')

% COSTO TOTALE E TEMPO DI TRASFERIMENTO DELLA MISSIONE

dv_TOT = abs(dv_1) + abs(dv_2) + abs(dv_3);   % 2.5522 km/s ~= 2.55 km/s
dt_TOT_sec = dt1 + dt2 + dt3 + dt4 + dt5; % 23189 sec = 6 hr 21 min 56 s
[h, m, s] = time2esa(dt_TOT_sec);

fprintf('%cv AF2P: %.2f km/s\n', 916, dv_TOT)
fprintf('%ct AF2P: %.0f s = %.0f hr %.0f min %.0f s\n', 916, dt_TOT_sec, h, m, s)

% AF2P leggermente più costosa di AF1P, ma comunque più breve di qualche minuto

%% MAVORA APF1
% Prova finale
% MANOVRA APF1
clear;
close all;

mu = 398600;

% Orbita iniziale
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
%plotOrbit(kepEli, mu, .1)
plot3(r0(1), r0(2), r0(3), 'o', 'MarkerSize', 10, 'MarkerEdgeColor', 'r', 'LineWidth', 3)
hold on

% Table Compiling, Initial data
TableCompiler( kepEli , 0 , 0, 'Given initial data')
% Orbita finale
kepElf = [11860.0000, 0.2614, rad2deg(0.5352), rad2deg(0.8005), rad2deg(2.3120), rad2deg(0.9719)];
fprintf('Parametri kepleriani orbita finale: [%.2f %.4f %.2f %.2f %.2f %.2f]\n', kepElf(1), kepElf(2), kepElf(3), kepElf(4), kepElf(5), kepElf(6))
%plotOrbit(kepElf, mu, .1)
hold on
[rf, ~] = kep2car(kepElf(1), kepElf(2), kepElf(3), kepElf(4), kepElf(5), kepElf(6), mu);
plot3(rf(1), rf(2), rf(3), 'x', 'MarkerSize', 15, 'MarkerEdgeColor', 'r', 'LineWidth', 3)

hold on

% % Perigei
% [p1, ~] = kep2car(kepEli(1), kepEli(2), kepEli(3), kepEli(4), kepEli(5), 0, mu);
% plot3(p1(1), p1(2), p1(3),  'k.', 'MarkerSize', 30);
% [p2, ~] = kep2car(kepElf(1), kepElf(2), kepElf(3), kepElf(4), kepElf(5), 0, mu);
% plot3(p2(1), p2(2), p2(3), 'k.', 'MarkerSize', 30);

% cambio anomalia -> cambio piano (causante un cambio di w) -> cambio forma 1

% ALLINEAMENTO ASSI ECCENTRICITA'

a_i = kepEli(1);
e_i = kepEli(2); 
i_i = kepEli(3);
OM_i = kepEli(4); 
om_i = kepEli(5); 
th_i = kepEli(6);

a_f = 11860;
e_f = 0.2614; 
i_f = kepElf(3);
OM_f = kepElf(4); 
om_f = kepElf(5); 
theta_f = kepElf(6);

om_st = om_f - (144.12175 - om_f); % anomalia del perigeo "strategico", il quale permette di ottenere
...in seguito al cambio di piano (nel corrispettivo punto di manovra) l'anomalia di perigeo richiesta per l'orbita finale.

[dv_1, thm ,thf1, dt1 ] = changePerArg (a_i, e_i, om_i , om_st , th_i);
TableCompiler( [kepEli(1:4) om_st thm] , dv_1 , dt1, 'APF1 maneuver')
TableCompiler( [kepEli(1:4) om_st thf1] , dv_1 , dt1, 0)
plotOrbitQuiver([a_i , e_i , i_i , OM_i , om_i , th_i ], mu, 5 , thm)  % tratto 1
hold on

% CAMBIO DI PIANO (INCLINAZIONE + ASCENSIONE RETTA DEL NODO ASCENDENTE)

[dv_2, wf , thf2, dt2] = changeOrbPlane (a_i, e_i, i_i, OM_i, om_st, i_f, OM_f, thf1);
TableCompiler( [a_i e_i kepElf(3:4) wf thf2] , dv_2 , dt1+dt2, 0)
plotOrbitQuiver([a_i , e_i , i_i , OM_i , om_st , thf1 ], mu, 5 , thf2)  % tratto 2
hold on
plotOrbitQuiver([a_i , e_i , i_f , OM_f , wf , thf2 ], mu, 5 , 180 )  % tratto 3

% Tempo di trasferimento dal punto di cambio a piano (thf2) al punto di cambio forma (apogeo: 180°)
dt3 = flightTime (a_i, e_i, thf2, 180);
TableCompiler( [a_i e_i kepElf(3:4) wf 180] , dv_2 , dt1+dt2+dt3, 0)

hold on

% CAMBIO FORMA (apocentro orbita iniziale -> pericentro orbita finale) 
[dvi, dvf, th, dt4, a_t, e_t] = biTangent (a_i, e_i, a_f, e_f, 180);
TableCompiler( [a_t e_t kepElf(3:4) wf 180] , dvi , dt1+dt2+dt3, 0)
TableCompiler( [kepElf(1:4) wf 0] , dvf , dt1+dt2+dt3+dt4, 0)

dv_3 = dvi + dvf;

plotOrbitQuiver([a_t , e_t , i_f , OM_f , wf , 180 ], mu, 5 , 0) % tratto 4 

hold on

plotOrbitQuiver([a_f , e_f , i_f , OM_f , wf , 0 ], mu, 5 , theta_f) % tratto 5

% Tempo di trasferimento dal perigeo della nuova orbita al punto d'arrivo (theta_f)
dt5 = flightTime (a_f, e_f, 0 , theta_f);
TableCompiler( [kepElf(1:6)] , 0 , dt1+dt2+dt3+dt4+dt5, 0)

hold on

Terra3d

%plotOrbit(kepEli, mu, .1)
plot3(r0(1), r0(2), r0(3), 'o', 'MarkerSize', 10, 'MarkerEdgeColor', 'r', 'LineWidth', 3);

%plotOrbit(kepElf, mu, .1)
plot3(rf(1), rf(2), rf(3), 'x', 'MarkerSize', 15, 'MarkerEdgeColor', 'r', 'LineWidth', 3);

xlim([-1.5*10000 1.5*10000])
ylim([-1.5*10000 1.5*10000])
zlim([-1.5*10000 1.5*10000])

legend('Init Pos', 'Fin Pos', 'Orb Init', 'Periapsis Arg Changed',  'Plane Changed' , 'Shape Changed', 'Orb Fin')

title('APF1 procedure')

% COSTO TOTALE E TEMPO DI TRASFERIMENTO DELLA MISSIONE

dv_TOT = abs(dv_1) + abs(dv_2) + abs(dv_3);   % 2.3491 km/s ~= 2.35 km/s
dt_TOT_sec = dt1 + dt2 + dt3 + dt4 + dt5; % 10335 sec = 2 hr 52 min 15 sec
[h, m, s] = time2esa(dt_TOT_sec);

fprintf('%cv APF1: %.2f km/s\n', 916, dv_TOT)
fprintf('%ct APF1: %.0f s = %.0f hr %.0f min %.0f s\n', 916, dt_TOT_sec, h, m, s)

%% MANOVRA APF2
clear;
close all;
clc;
mu = 398600;

% Orbita iniziale
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
%plotOrbit(kepEli, mu, .1)
plot3(r0(1), r0(2), r0(3), 'o', 'MarkerSize', 10, 'MarkerEdgeColor', 'r', 'LineWidth', 3)
hold on

% Orbita finale
kepElf = [11860.0000, 0.2614, rad2deg(0.5352), rad2deg(0.8005), rad2deg(2.3120), rad2deg(0.9719)];
fprintf('Parametri kepleriani orbita finale: [%.2f %.4f %.2f %.2f %.2f %.2f]\n', kepElf(1), kepElf(2), kepElf(3), kepElf(4), kepElf(5), kepElf(6))
%plotOrbit(kepElf, mu, .1)
hold on
[rf, ~] = kep2car(kepElf(1), kepElf(2), kepElf(3), kepElf(4), kepElf(5), kepElf(6), mu);
plot3(rf(1), rf(2), rf(3), 'x', 'MarkerSize', 15, 'MarkerEdgeColor', 'r', 'LineWidth', 3)

hold on

% % Perigei
% [p1, ~] = kep2car(kepEli(1), kepEli(2), kepEli(3), kepEli(4), kepEli(5), 0, mu);
% plot3(p1(1), p1(2), p1(3),  'k.', 'MarkerSize', 30);
% [p2, ~] = kep2car(kepElf(1), kepElf(2), kepElf(3), kepElf(4), kepElf(5), 0, mu);
% plot3(p2(1), p2(2), p2(3), 'k.', 'MarkerSize', 30);

% cambio anomalia -> cambio piano (causante un cambio di w) -> cambio forma (2)

% ALLINEAMENTO ASSI ECCENTRICITA'

a_i = kepEli(1);
e_i = kepEli(2); 
i_i = kepEli(3);
OM_i = kepEli(4); 
om_i = kepEli(5); 
th_i = kepEli(6);

a_f = 11860;
e_f = 0.2614; 
i_f = kepElf(3);
OM_f = kepElf(4); 
om_f = kepElf(5); 
theta_f = kepElf(6);

% Table Compiling, Initial data
TableCompiler( kepEli , 0 , 0, 'Given initial data')

om_st = om_f - (144.12175 - om_f); % anomalia del perigeo "strategico", il quale permette di ottenere
...in seguito al cambio di piano (nel corrispettivo punto di manovra) l'anomalia di perigeo richiesta per l'orbita finale.

[dv_1, thm ,thf1, dt1 ] = changePerArg (a_i, e_i, om_i , om_st , th_i);
%[delta_T] = timeOfFlight (a_i,e_i,th_ir,thm);
TableCompiler( [kepEli(1:5) thm] , dv_1 , dt1, 'APF2 maneuver')
TableCompiler( [kepEli(1:4) om_st thf1] , dv_1 , dt1, 0)

plotOrbitQuiver([a_i , e_i , i_i , OM_i , om_i , th_i ], mu, 5 , thm)  % tratto 1
hold on

% CAMBIO DI PIANO (INCLINAZIONE + ASCENSIONE RETTA DEL NODO ASCENDENTE)
[dv_2, wf , thf2, dt2] = changeOrbPlane (a_i, e_i, i_i, OM_i, om_st, i_f, OM_f, thf1);
TableCompiler( [a_i e_i kepElf(3:5) thf2] , dv_2 , dt1+dt2, 0)
plotOrbitQuiver([a_i , e_i , i_i , OM_i , om_st , thf1 ], mu, 5 , thf2)  % tratto 2

hold on

plotOrbitQuiver([a_i , e_i , i_f , OM_f , wf , thf2 ], mu, 5 , 0 )  % tratto 3

% Tempo di trasferimento dal punto di cambio a piano (thf2) al punto di cambio forma (perigeo: 0°)
dt3 = flightTime (a_i, e_i, thf2, 0);
TableCompiler( [a_i e_i kepElf(3:5) 0] , 0 , dt3, 0)

hold on

% CAMBIO FORMA (pericentro orbita iniziale -> apocentro orbita finale) 
[dvi, dvf, th, dt4, a_t, e_t] = biTangent (a_i, e_i, a_f, e_f, 0);
dv_3 = dvi + dvf;
TableCompiler( [a_t e_t kepElf(3:4) wf 180] , dvi , dt1+dt2+dt3, 0)
TableCompiler( [kepElf(1:4) wf 0] , dvf , dt1+dt2+dt3+dt4, 0)

plotOrbitQuiver([a_t , e_t , i_f , OM_f , wf , 0 ], mu, 5 , 180) % tratto 4 

hold on

plotOrbitQuiver([a_f , e_f , i_f , OM_f , wf , 180 ], mu, 5 , theta_f) % tratto 5

% Tempo di trasferimento dal perigeo della nuova orbita al punto d'arrivo (theta_f)
dt5 = flightTime (a_f, e_f, 180 , theta_f);
TableCompiler( kepElf ,0, dt1+dt2+dt3+dt4+dt5, 0)
hold on

Terra3d

%plotOrbit(kepEli, mu, .1)
plot3(r0(1), r0(2), r0(3), 'o', 'MarkerSize', 10, 'MarkerEdgeColor', 'r', 'LineWidth', 3);

%plotOrbit(kepElf, mu, .1)
plot3(rf(1), rf(2), rf(3), 'x', 'MarkerSize', 15, 'MarkerEdgeColor', 'r', 'LineWidth', 3);

xlim([-1.5*10000 1.5*10000])
ylim([-1.5*10000 1.5*10000])
zlim([-1.5*10000 1.5*10000])

legend('Init Pos', 'Fin Pos', 'Orb Init','', 'Periapsis Arg Changed','',  'Plane Changed' ,'', 'Shape Changed','', 'Orb Fin')

title('APF2 procedure')

% COSTO TOTALE E TEMPO DI TRASFERIMENTO DELLA MISSIONE

dv_TOT = abs(dv_1) + abs(dv_2) + abs(dv_3);   % 2.3428 km/s
dt_TOT_sec = dt1 + dt2 + dt3 + dt4 + dt5; % 22916 sec = 6 hr 21 min 56 sec
[h, m, s] = time2esa(dt_TOT_sec);

fprintf('%cv APF2: %.2f km/s\n', 916, dv_TOT)
fprintf('%ct APF2: %.0f s = %.0f hr %.0f min %.0f s\n', 916, dt_TOT_sec, h, m, s)

% Come ci si poteva aspettare, APF2 più svantaggiosa di APF1

%% MANOVRA F1AP
clear;
close all;
clc
mu = 398600;

% Orbita iniziale
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
%plotOrbit(kepEli, mu, .1)
plot3(r0(1), r0(2), r0(3), 'o', 'MarkerSize', 10, 'MarkerEdgeColor', 'r', 'LineWidth', 3)
hold on

% Orbita finale
kepElf = [11860.0000, 0.2614, rad2deg(0.5352), rad2deg(0.8005), rad2deg(2.3120), rad2deg(0.9719)];
fprintf('Parametri kepleriani orbita finale: [%.2f %.4f %.2f %.2f %.2f %.2f]\n', kepElf(1), kepElf(2), kepElf(3), kepElf(4), kepElf(5), kepElf(6))
%plotOrbit(kepElf, mu, .1)
hold on
[rf, ~] = kep2car(kepElf(1), kepElf(2), kepElf(3), kepElf(4), kepElf(5), kepElf(6), mu);
plot3(rf(1), rf(2), rf(3), 'x', 'MarkerSize', 15, 'MarkerEdgeColor', 'r', 'LineWidth', 3)

hold on

% % Perigei
% [p1, ~] = kep2car(kepEli(1), kepEli(2), kepEli(3), kepEli(4), kepEli(5), 0, mu);
% plot3(p1(1), p1(2), p1(3),  'k.', 'MarkerSize', 30);
% [p2, ~] = kep2car(kepElf(1), kepElf(2), kepElf(3), kepElf(4), kepElf(5), 0, mu);
% plot3(p2(1), p2(2), p2(3), 'k.', 'MarkerSize', 30);

% cambio forma (1) ->  cambio anomalia ->  cambio piano

a_i = kepEli(1);
e_i = kepEli(2); 
i_i = kepEli(3);
OM_i = kepEli(4); 
om_i = kepEli(5); 
th_i = kepEli(6);

a_f = 11860;
e_f = 0.2614; 
i_f = kepElf(3);
OM_f = kepElf(4); 
om_f = kepElf(5); 
theta_f = kepElf(6);

plotOrbitQuiver([a_i , e_i , i_i , OM_i , om_i , th_i ], mu, 5, 180)  % tratto 1
% Table Compiling, Initial data
TableCompiler( kepEli , 0 , 0, 'Given initial data')
% Orbita finale
% Tempo di trasferimento dal punto di rilascio all'apocentro (dove effettuare il cambio di forma)
dt1 = flightTime (a_i, e_i, th_i, 180);
TableCompiler( [kepEli(1:5) 180] , 0 , dt1, 'F1AP maneuver')

hold on

% CAMBIO FORMA 1  (apocentro orbita iniziale -> pericentro orbita finale)

[dvi, dvf, th, dt2, a_t, e_t] = biTangent (a_i, e_i, a_f, e_f, 180);
dv_1 = dvi + dvf;
TableCompiler( [a_t e_t kepEli(3:5) 180] , dvi , dt1, 0)
TableCompiler( [kepElf(1:2) kepEli(3:5) 0] , dvf , dt1+dt2, 0)

plotOrbitQuiver([a_t , e_t , i_i , OM_i , om_i , 180 ], mu, 5 , 0)  % tratto 2

hold on

% CAMBIO ANOMALIA

om_st = om_f - (144.12175 - om_f); % anomalia del perigeo "strategico", il quale permette di ottenere
...in seguito al cambio di piano (nel corrispettivo punto di manovra) l'anomalia di perigeo richiesta per l'orbita finale.

[dv_2, thm ,thf1, dt3] = changePerArg (a_f , e_f, om_i , om_st , 0);
dv_2
TableCompiler( [kepElf(1:2) kepEli(3:5) thm] , dv_2 , dt1+dt2+dt3, 0)
TableCompiler( [kepElf(1:2) kepEli(3:4) om_st thf1] , 0 , dt1+dt2+dt3, 0)

plotOrbitQuiver([a_f , e_f , i_i , OM_i , om_i , 0 ], mu, 5, thm)  % tratto 3

hold on
% CAMBIO PIANO
[dv_3, wf, thf, dt4] = changeOrbPlane (a_f, e_f, i_i, OM_i, om_st, i_f, OM_f, thf1);
TableCompiler( [kepElf(1:4) wf thf] , dv_3 , dt1+dt2+dt3+dt4, 0)

plotOrbitQuiver([a_f , e_f , i_i , OM_i , om_st , thf1 ], mu, 5, thf)  % tratto 4

plotOrbitQuiver([a_f , e_f , i_f , OM_f , wf , thf ], mu, 5 , theta_f)  % tratto 5

% Tempo di trasferimento dal punto di cambio piano al punto di rilascio
dt5 = flightTime (a_f, e_f, thf , theta_f);
TableCompiler( [kepElf(1:6)] , 0 , dt1+dt2+dt3+dt4+dt5, 0)

hold on

Terra3d

xlim([-1.5*10000 1.5*10000])
ylim([-1.5*10000 1.5*10000])
zlim([-1.5*10000 1.5*10000])

legend('Init Pos', 'Fin Pos', 'Orb Init','Shape Changed', 'Periapsis Arg Changed' , 'Plane Changed' , 'Orb Fin')

title('F1AP procedure')

% COSTO TOTALE E TEMPO DI TRASFERIMENTO DELLA MISSIONE

dv_TOT = abs(dv_1) + abs(dv_2) + abs(dv_3);   % 3.8955 km/s ~= 3.90 km/s
dt_TOT_sec = dt1 + dt2 + dt3 + dt4 + dt5; % 9538 sec = 2 hr 38 min 58 s
[h, m, s] = time2esa(dt_TOT_sec);

fprintf('%cv F1AP: %.2f km/s\n', 916, dv_TOT)
fprintf('%ct F1AP: %.0f s = %.0f hr %.0f min %.0f s\n', 916, dt_TOT_sec, h, m, s)

%% MANOVRA PAF2
clear;
close all;
clc;
mu = 398600;

% Orbita iniziale
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
%plotOrbit(kepEli, mu, .1)
plot3(r0(1), r0(2), r0(3), 'o', 'MarkerSize', 10, 'MarkerEdgeColor', 'r', 'LineWidth', 3)
hold on
% Table Compiling, Initial data
TableCompiler( kepEli , 0 , 0, 'Given initial data')

% Orbita finale
kepElf = [11860.0000, 0.2614, rad2deg(0.5352), rad2deg(0.8005), rad2deg(2.3120), rad2deg(0.9719)];
fprintf('Parametri kepleriani orbita finale: [%.2f %.4f %.2f %.2f %.2f %.2f]\n', kepElf(1), kepElf(2), kepElf(3), kepElf(4), kepElf(5), kepElf(6))
%plotOrbit(kepElf, mu, .1)
hold on
[rf, ~] = kep2car(kepElf(1), kepElf(2), kepElf(3), kepElf(4), kepElf(5), kepElf(6), mu);
plot3(rf(1), rf(2), rf(3), 'x', 'MarkerSize', 15, 'MarkerEdgeColor', 'r', 'LineWidth', 3)

hold on

% % Perigei
% [p1, ~] = kep2car(kepEli(1), kepEli(2), kepEli(3), kepEli(4), kepEli(5), 0, mu);
% plot3(p1(1), p1(2), p1(3),  'k.', 'MarkerSize', 30);
% [p2, ~] = kep2car(kepElf(1), kepElf(2), kepElf(3), kepElf(4), kepElf(5), 0, mu);
% plot3(p2(1), p2(2), p2(3), 'k.', 'MarkerSize', 30);

% cambio piano -> cambio anomalia -> cambio forma (2)

% ALLINEAMENTO ASSI ECCENTRICITA'

a_i = kepEli(1);
e_i = kepEli(2); 
i_i = kepEli(3);
OM_i = kepEli(4); 
om_i = kepEli(5); 
th_i = kepEli(6);

a_f = 11860;
e_f = 0.2614; 
i_f = kepElf(3);
OM_f = kepElf(4); 
om_f = kepElf(5); 
theta_f = kepElf(6);

% CAMBIO PIANO
[dv_1, wf, thf, dt1] = changeOrbPlane (a_i, e_i, i_i, OM_i, om_i, i_f, OM_f, th_i);
TableCompiler( [kepEli(1:5) thf ] , dv_1 , dt1, 'PAF2 maneuver')
TableCompiler( [kepEli(1:2) kepElf(3:4) wf thf ] , dv_1 , dt1, 0)

plotOrbitQuiver([a_i , e_i , i_i , OM_i , om_i , th_i ], mu, 5 , thf)  % tratto 1

hold on

% CAMBIO ANOMALIA
[dv_2, thm ,thf1, dt2 ] = changePerArg (a_i, e_i, wf , om_f , thf);
TableCompiler( [kepEli(1:2) kepElf(3:4) wf thm] , dv_2 , dt1+dt2 , 0)
TableCompiler( [kepEli(1:2) kepElf(3:4) om_f thf1] , dv_2 , dt1+dt2 , 0)


plotOrbitQuiver([a_i , e_i , i_f , OM_f , wf , thf ], mu, 5 , thm)  % tratto 2

hold on

plotOrbitQuiver([a_i , e_i , i_f , OM_f , om_f , thf1 ], mu, 5, 0)  % tratto 3: trasferimento dal punto di cambio anomalia al pericentro

hold on

% Tempo di trasferimento dal punto di cambio anomalia al pericentro
dt3 = flightTime (a_i, e_i, thf1, 0);
TableCompiler( [kepEli(1:2) kepElf(3:4) wf 0] , 0 , dt1+dt2+dt3 , 0)

% CAMBIO FORMA (pericentro orbita iniziale -> apocentro orbita finale)

[dvi, dvf, th, dt4, a_t, e_t] = biTangent (a_i, e_i, a_f, e_f, 0);
dv_3 = dvi + dvf;
TableCompiler( [kepEli(1:2) kepElf(3:4) wf 0] , dvi , dt1+dt2+dt3 , 0)
TableCompiler( [a_t e_t kepElf(3:4) wf 180] , dvf , dt1+dt2+dt3+dt4 , 0)
TableCompiler( [kepElf(1:4) wf th] , dvf , dt1+dt2+dt3+dt4 , 0)

plotOrbitQuiver([a_t , e_t , i_f , OM_f , om_f , 0 ], mu, 5 , 180)  % tratto 4

hold on

plotOrbitQuiver([a_f , e_f , i_f , OM_f , om_f , 180 ], mu, 5 , theta_f)  % tratto 5

% Tempo di trasferimento dal punto di cambio forma al punto di rilascio
dt5 = flightTime (a_f, e_f, 180, theta_f);
TableCompiler( kepElf , 0 , dt1+dt2+dt3+dt4+dt5 , 0 )

Terra3d

xlim([-1.5*10000 1.5*10000])
ylim([-1.5*10000 1.5*10000])
zlim([-1.5*10000 1.5*10000])

legend('Init Pos', 'Fin Pos', 'Orb Init','', 'Periapsis Arg Changed','', 'Shape Changed' ,'', 'Plane Changed' ,'', 'Orb Fin')

title('PAF2 procedure')

% COSTO TOTALE E TEMPO DI TRASFERIMENTO DELLA MISSIONE

dv_TOT = abs(dv_1) + abs(dv_2) + abs(dv_3);   % 2.5522 km/s ~= 2.42 km/s
dt_TOT_sec = dt1 + dt2 + dt3 + dt4 + dt5; % 23189 sec = 6 hr 7 min 59 s
[h, m, s] = time2esa(dt_TOT_sec);

fprintf('%cv PAF2: %.2f km/s\n', 916, dv_TOT)
fprintf('%ct PAF2: %.0f s = %.0f hr %.0f min %.0f s\n', 916, dt_TOT_sec, h, m, s)

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

%% MANOVRA DIRETTA

% ESEMPIO
thm1 = rand*360; % da quale anomalia dell'orbita iniziale si vuole partire (default = kepEli(6), pos init)
thm2 = rand*360; % a quale anomalia vera dell'orbita finale si vuole arrivare (default = kepElf(6), pos fin)
et = rand; % quale eccentricità si vuole che l'orbita di trasferimento abbia
[dvdir, dtdir, kepElt, th2t, dth, r1, r2, d1, d2, pt, v1, vt1, dv1, vt2, v2, dv2, dt0, dt1, dt2, thc1t, thc2t] = directOrb (kepEli, kepElf, et, thm1, thm2, 'best', 'on');
th1t = kepElt(6);

directGraphics (d1, d2, dth, et, th1t, th2t) % see graphical solution for requested situation

if ~isnan(dvdir)
    figure
    hold on
    grid on
    xlabel('X [km]')
    ylabel('Y [km]')
    zlabel('Z [km]')
    set(gca, 'FontSize', 12)
    plot3(r0(1), r0(2), r0(3), 'o', 'MarkerSize', 10, 'MarkerEdgeColor', 'r', 'LineWidth', 3)
    plot3(rf(1), rf(2), rf(3), 'x', 'MarkerSize', 15, 'MarkerEdgeColor', 'r', 'LineWidth', 3)
    % pbaspect([1 1 1])
    % daspect([1 1 1])
    view(30, 30)
    
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
end

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
ftarget = @(x) dirOrbv(kepEli, kepElf, x(1), x(2), x(3));
x0 = [0.2, 120, 150];
lb = [0.0001, 0, 0];
ub = [0.9999, 360, 360];
[xvmin, dvmin] = fminsearchbnd(ftarget, x0, lb, ub, optimset('Display','off'));
dtv = dirOrbt(kepEli, kepElf, xvmin(1), xvmin(2), xvmin(3));
[hv, mv, sv] = time2esa(dtv);
fprintf('Absolute minimum possible direct impulse value: %cv = %.2f km/s @ [%c1 = %.2f°, %c2 = %.2f°, e = %.4f, %ct = %.0f s (%.0f hr %.0f min %.0f s)]\n', 916, dvmin, 952, xvmin(2), 952, xvmin(3), xvmin(1), 916, dtv, hv, mv, sv)
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
[~, ~, kepElt, th2t, ~, r1, r2, ~, ~, ~, v1, vt1, ~,  vt2, v2] = directOrb (kepEli, kepElf, et, thm1, thm2);
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
% plotOrbit(kepEli,mu,.1)
% plotOrbit(kepElt,mu,.1)
% plotOrbit(kepElf,mu,.1)
legend('Init Pos', 'Fin Pos', 'Orb Init', 'Orb Trans', 'Orb Fin', '1e3*v1', '1e3*vt1', '1e3*vt2', '1e3*v2')
title('Most impulse-convenient direct transfer')
view(30,30)

% time-oriented min research
ftarget = @(x) dirOrbt(kepEli, kepElf, x(1), x(2), x(3));
x0 = [0.7, 130, 50];
lb = [0.0001, 0, 0];
ub = [0.9999, 360, 360];
[xtmin, dtmin] = fminsearchbnd(ftarget, x0, lb, ub, optimset('Display','off'));
[ht, mt, st] = time2esa(dtmin);
dvt = dirOrbv(kepEli, kepElf, xtmin(1), xtmin(2), xtmin(3));
fprintf('Absolute minimum possible direct flight time value: %ct = %.0f s (%.0f hr %.0f min %.0f s) @ [%c1 = %.2f°, %c2 = %.2f°, e = %.4f, %cv = %.2f km/s]\n', 916, dtmin, ht, mt, st, 952, xtmin(2), 952, xtmin(3), xtmin(1), 916, dvt)
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
[~, ~, kepElt, th2t, ~, r1, r2, ~, ~, ~, v1, vt1, ~, vt2, v2] = directOrb (kepEli, kepElf, et, thm1, thm2);
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
% plotOrbit(kepEli,mu,.1)
% plotOrbit(kepElt,mu,.1)
% plotOrbit(kepElf,mu,.1)
legend('Init Pos', 'Fin Pos', 'Orb Init', 'Orb Trans', 'Orb Fin', '1e3*v1', '1e3*vt1', '1e3*vt2', '1e3*v2')
title('Most time-convenient direct transfer')
view(30,30)

%% Finding velocity & time minimum combinations

stepth0 = 60; % angle resolution (recommended: 60°)
thm10min = 0;
thm10max = 360;
thm20min = 0;
thm20max = 360;
stepe0 = .1; % eccentricity resolution (recommended: 0.1)
et0min = .1;
et0max = .9;
et0 = et0min:stepe0:et0max;
thm10 = thm10min:stepth0:thm10max;
thm20 = thm20min:stepth0:thm20max;
lb = [0.0001, 0, 0];
ub = [0.9999, 360, 360];
ftarget = @(x) dirOrbv(kepEli, kepElf, x(1), x(2), x(3));

Dv = zeros(length(et0)*length(thm10)*length(thm20), 5);
i = 0;
tic
for et0 = et0min:stepe0:et0max
    for thm10 = thm10min:stepth0:thm10max
        for thm20 = thm20min:stepth0:thm20max
            x0 = [et0, thm10, thm20];
            [xvmin, dvmin] = fminsearchbnd(ftarget, x0, lb, ub, optimset('Display','off'));
            i = i + 1;
            dtv = dirOrbt(kepEli, kepElf, xvmin(1), xvmin(2), xvmin(3));
            Dv(i, :) = [dvmin dtv xvmin];
        end
    end
end
elapsed = toc;
[h, m, s] = time2esa(elapsed);
fprintf('Velocity minimums found: %d\n', i)
fprintf('Time elapsed: %.0f hr %.0f min %.0f s\n', h, m, s)
Dv = Dv(isfinite(Dv(:,1)), :);
Dv(:, end+1) = Dv(:, 1) / norm(Dv(:, 1));
Dv(:, end+1) = Dv(:, 2) / norm(Dv(:, 2));
wv = 100; % importance given to velocity
wt = 0; % importance given to time
Dv(:, end+1) = wv*Dv(:, end-1)+wt*Dv(:, end);
Dv = sortrows(Dv, size(Dv, 2));
Dv = Dv(:, 1:5);

Dt = zeros(length(et0)*length(thm10)*length(thm20), 5);
j = 0;
tic
for et0 = et0min:stepe0:et0max
    for thm10 = thm10min:stepth0:thm10max
        for thm20 = thm20min:stepth0:thm20max
            ftarget = @(x) dirOrbt(kepEli, kepElf, x(1), x(2), x(3));
            x0 = [et0, thm10, thm20];
            [xtmin, dtmin] = fminsearchbnd(ftarget, x0, lb, ub, optimset('Display','off'));
            j = j + 1;
            dvt = dirOrbv(kepEli, kepElf, xtmin(1), xtmin(2), xtmin(3));
            Dt(j, :) = [dvt dtmin xtmin];
        end
    end
end
elapsed = toc;
[h, m, s] = time2esa(elapsed);
fprintf('Time minimums found: %d\n', j)
fprintf('Time elapsed: %.0f hr %.0f min %.0f s\n', h, m, s)
Dt = Dt(isfinite(Dt(:,1)), :);
Dt(:, end+1) = Dt(:, 1) / norm(Dt(:, 1));
Dt(:, end+1) = Dt(:, 2) / norm(Dt(:, 2));
wv = 0; % importance given to velocity
wt = 100; % importance given to time
Dt(:, end+1) = wv*Dt(:, end-1)+wt*Dt(:, end);
Dt = sortrows(Dt, size(Dt, 2));
Dt = Dt(:, 1:5);

%% Finding best overall direct transfer

Dv = Dv(isfinite(Dv(:,1)), :);
Dt = Dt(isfinite(Dt(:,1)), :);

% Dt = Dt(Dt(:, 2)<min(Dv(:, 2)), :);
% Dv = Dv(Dv(:, 1)<min(Dt(:, 1)), :);

Dv = sortrows(Dv, 1);
[~, dvs] = uniquetol(Dv(:,1), 1e-2, 'DataScale', 1);
Dt = sortrows(Dt, 2);
[~, dts] = uniquetol(Dt(:,2), 60, 'DataScale', 1);

figure
scatter(Dv(dvs,2)/3600, Dv(dvs,1), 'b', 'filled')
grid minor
xlabel('Time [hr]', 'Interpreter', 'latex')
ylabel('Impulse [km/s]', 'Interpreter', 'latex')
title('Impulse minimums vs. Time', 'Interpreter', 'latex')
set(gca, 'FontSize', 12)

figure
scatter(Dt(dts,2)/3600, Dt(dts,1), 'r', 'filled')
grid minor
xlabel('Time [hr]', 'Interpreter', 'latex')
ylabel('Impulse [km/s]', 'Interpreter', 'latex')
title('Time minimums vs. Impulse', 'Interpreter', 'latex')
set(gca, 'FontSize', 12)

figure
hold on
grid minor
scatter(Dv(dvs,2)/3600, Dv(dvs,1), 'b', 'filled')
scatter(Dt(dts,2)/3600, Dt(dts,1), 'r', 'filled')
xlabel('Time [hr]', 'Interpreter', 'latex')
ylabel('Impulse [km/s]', 'Interpreter', 'latex')
legend('Impulse minimums vs. Time', 'Time minimums vs. Impulse', 'Interpreter', 'latex')
title('Minimum direct trasfer combinations', 'Interpreter', 'latex')
set(gca, 'FontSize', 12)

D = [Dv; Dt];
D = D(isfinite(D(:,1)), :);
D(:, end+1) = D(:, 1) / norm(D(:, 1));
D(:, end+1) = D(:, 2) / norm(D(:, 2));
% D(:, end+1) = (D(:, 1) - mean(D(:, 1))) / std(D(:, 1));
% D(:, end+1) = (D(:, 2) - mean(D(:, 2))) / std(D(:, 2));
% D(:, end+1) = (D(:, 1) - min(D(:, 1))) / (max(D(:, 1)) - min(D(:, 1)));
% D(:, end+1) = (D(:, 2) - min(D(:, 2))) / (max(D(:, 2)) - min(D(:, 2)));
wv = 90; % importance given to velocity
wt = 10; % importance given to time
D(:, end+1) = 1./(wv*D(:, end-1)+wt*D(:, end)); % convenience
D = sortrows(D, size(D, 2), 'descend');
D = D(:, 1:5);

dirbest = D(1, 3:end); % best overall maneuver
et = dirbest(1);
thm1 = dirbest(2);
thm2 = dirbest(3);

figure
hold on
grid on
xlabel('$X$ [km]', 'Interpreter', 'latex')
ylabel('$Y$ [km]', 'Interpreter', 'latex')
zlabel('$Z$ [km]', 'Interpreter', 'latex')
set(gca, 'FontSize', 12)
plot3(r0(1), r0(2), r0(3), 'o', 'MarkerSize', 10, 'MarkerEdgeColor', 'r', 'LineWidth', 3)
plot3(rf(1), rf(2), rf(3), 'x', 'MarkerSize', 15, 'MarkerEdgeColor', 'r', 'LineWidth', 3)
[dvdir, dtdir, kepElt, th2t, ~, r1, r2, ~, ~, ~, v1, vt1, ~, vt2, v2, ~, ~, ~, ~] = directOrb (kepEli, kepElf, et, thm1, thm2);
[h, m, s] = time2esa (dtdir);
fprintf('%cv complessivo manovra diretta ottimale: %.2f km/s\n', 916, dvdir)
fprintf('%ct complessivo manovra diretta ottimale: %.0f s = %.0f hr %.0f min %.0f s\n', 916, dtdir, h, m, s)

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
legend('Init Pos', 'Fin Pos', 'Orb Init', 'Orb Trans', 'Orb Fin', '$v1 \cdot 10^3$', '$vt1 \cdot 10^3$', '$vt1 \cdot 10^3$', '$v2 \cdot 10^3$', 'Interpreter', 'latex')
title(sprintf('Best overall direct transfer'), 'Interpreter', 'latex')
fprintf('Best overall direct transfer: from %.2f° to %.2f° at e = %.4f\n', thm1, thm2, et)
view(30, 30)
