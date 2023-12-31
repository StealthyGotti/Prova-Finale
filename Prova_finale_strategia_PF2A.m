% Prova finale
% MANOVRA PF2A
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

%% MAVORA PF2A

% cambio piano -> cambio forma (2) -> cambio anomalia

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

plotOrbitQuiver([a_i , e_i , i_i , OM_i , om_i , th_i ], mu, 5 , thf)  % tratto 1

hold on

plotOrbitQuiver([a_i , e_i , i_f , OM_f , wf , thf ], mu, 5 , 0 )  % tratto 2: trasferimento dal punto di cambio piano al pericentro

% Tempo di trasferimento dal punto di cambio piano al pericentro
dt2 = flightTime (a_i, e_i, thf, 0);

% CAMBIO FORMA (pericentro orbita iniziale -> apocentro orbita finale)
[dvi, dvf, thf, dt3, a_t, e_t] = biTangent (a_i, e_i, a_f, e_f, 0);
dv_2 = dvi + dvf;

plotOrbitQuiver([a_t , e_t , i_f , OM_f , wf , 0 ], mu, 5 , 180 )  % tratto 3

hold on

% CAMBIO ANOMALIA
[dv_3, thm ,thf1, dt4 ] = changePerArg (a_f, e_f, wf , om_f , 180 );

plotOrbitQuiver([a_f , e_f , i_f , OM_f , wf , 180 ], mu, 5 , thm)  % tratto 4

hold on

plotOrbitQuiver([a_f , e_f , i_f , OM_f , om_f , thf1 ], mu, 5 , theta_f)  % tratto 5

% Tempo di trasferimento dal punto di cambio forma al punto di rilascio
dt5 = flightTime (a_f, e_f, thf1, theta_f);

Terra3d

xlim([-1.5*10000 1.5*10000])
ylim([-1.5*10000 1.5*10000])
zlim([-1.5*10000 1.5*10000])

legend('Init Pos', 'Fin Pos', 'Orb Init' , 'Plane Changed', 'Shape Changed' ,'Periapsis Arg Changed', 'Orb Fin')


title('PF2A procedure')

%% COSTO TOTALE E TEMPO DI TRASFERIMENTO DELLA MISSIONE

dv_TOT = abs(dv_1) + abs(dv_2) + abs(dv_3);   % 3.7566 km/s ~= 3.76 km/s
dt_TOT_sec = dt1 + dt2 + dt3 + dt4 + dt5; % 23189 sec = 7 hr 1 min 20 s
[h, m, s] = time2esa(dt_TOT_sec);

fprintf('%cv AF1P: %.2f km/s\n', 916, dv_TOT)
fprintf('%ct AF1P: %.0f s = %.0f hr %.0f min %.0f s\n', 916, dt_TOT_sec, h, m, s)
