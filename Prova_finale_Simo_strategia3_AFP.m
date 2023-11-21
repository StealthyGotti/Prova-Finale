% Prova finale (Simo)
% STRATEGIA 3: MANOVRA AFP
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
plotOrbit(kepEli, mu, .1)
plot3(r0(1), r0(2), r0(3), 'o', 'MarkerSize', 10, 'MarkerEdgeColor', 'r', 'LineWidth', 3)
hold on

% Orbita finale
kepElf = [11860.0000, 0.2614, rad2deg(0.5352), rad2deg(0.8005), rad2deg(2.3120), rad2deg(0.9719)];
fprintf('Parametri kepleriani orbita finale: [%.2f %.4f %.2f %.2f %.2f %.2f]\n', kepElf(1), kepElf(2), kepElf(3), kepElf(4), kepElf(5), kepElf(6))
plotOrbit(kepElf, mu, .1)
hold on
[rf, ~] = kep2car(kepElf(1), kepElf(2), kepElf(3), kepElf(4), kepElf(5), kepElf(6), mu);
plot3(rf(1), rf(2), rf(3), 'x', 'MarkerSize', 15, 'MarkerEdgeColor', 'r', 'LineWidth', 3)

hold on

% Perigei
[p1, ~] = kep2car(kepEli(1), kepEli(2), kepEli(3), kepEli(4), kepEli(5), 0, mu);
plot3(p1(1), p1(2), p1(3),  'k.', 'MarkerSize', 30);
[p2, ~] = kep2car(kepElf(1), kepElf(2), kepElf(3), kepElf(4), kepElf(5), 0, mu);
plot3(p2(1), p2(2), p2(3), 'k.', 'MarkerSize', 30);

%% PLOT ANIMATI

%[X_i , Y_i , Z_i] = plotOrbit_correct_Simo(a_i , e_i , i_i , OM_i , om_i , mu , 1);

%[X_f , Y_f , Z_f] = plotOrbit_correct_Simo(a_f , e_f , i_f , OM_f , om_f , mu , 1);

%% MAVORA AFP

% cambio anomalia -> cambio forma  -> cambio piano (causante un cambio di w)

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
[dv_1, thm ,thf1, dt_1 ] = changePerArg (a_i, e_i, om_i , om_st , th_i);
%[delta_T] = timeOfFlight (a_i,e_i,th_ir,thm);

plotOrbitQuiver([a_i , e_i , i_i , OM_i , om_i , th_i ], mu, 20, thm)  % tratto 1
hold on

plotOrbitQuiver([a_i , e_i , i_i , OM_i , om_st , thf1 ], mu, 5, 180)  % tratto 2
hold on

% Tempo di trasferimento dal punto di cambio anomalia all'apocentro
dt2 = flightTime (a_i, e_i, thf1, 180);

% CAMBIO FORMA
[delta_v2 , delta_t3 , a_t , e_t] = changeOrbitShape(a_i , e_i , om_st , a_f , e_f , om_st , 1);

plotOrbitQuiver([a_t , e_t , i_i , OM_i , om_st , 180 ], mu, 20, 0)  % tratto 3

hold on

% CAMBIO PIANO
[dv3, wf, thf, dt4] = changeOrbPlane (a_f, e_f, i_i, OM_i, om_st, i_f, OM_f, 0);

plotOrbitQuiver([a_f , e_f , i_i , OM_i , om_st , 0 ], mu, 20, thf)  % tratto 4

plotOrbitQuiver([a_f , e_f , i_f , OM_f , wf , thf ], mu, 20, theta_f)  % tratto 5

hold on

% Tempo di trasferimento dal punto di cambio piano al punto di rilascio
dt5 = flightTime (a_f, e_f, thf, theta_f);

Terra3d

title('Trasferimento AFP')

%% COSTO TOTALE E TEMPO DI TRASFERIMENTO DELLA MISSIONE

dv_TOT = abs(dv_1) + abs(delta_v2) + abs(dv3);   % 2.1626 km/s
dt_TOT_sec = dt_1 + dt2 + delta_t3 + dt4 + dt5; % 23189 sec
dt_TOT_ore = (dt_1 + dt2 + delta_t3 + dt4 + dt5)/3600; % 6.4415 ore ~= 6 ore e 26 minuti

fprintf('Costo totale della misione (km/s): [%.4f]\n', dv_TOT )

fprintf('Tempo totale di trasferimento con manovra AFP (sec): [%.0f]\n', dt_TOT_sec )
fprintf('Tempo totale di trasferimento con manovra AFP (ore): [%.4f]\n', dt_TOT_ore )


