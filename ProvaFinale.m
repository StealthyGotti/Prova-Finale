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
plot3(p1(1), p1(2), p1(3),  'k.', 'MarkerSize', 30);
[p2, ~] = kep2car(kepElf(1), kepElf(2), kepElf(3), kepElf(4), kepElf(5), 0, mu);
plot3(p2(1), p2(2), p2(3), 'k.', 'MarkerSize', 30);

% Equatorial Plane
[x, y] = meshgrid(-1.5*10000:50:1.5*10000, -10000*1.5:50:1.5*10000);
z = zeros(size(x));
surf(x, y, z, 'FaceAlpha', .75, 'EdgeColor', 'none', 'FaceColor', [.7 .7 .7]);
xlim([-1.5*10000 1.5*10000])
ylim([-1.5*10000 1.5*10000])
zlim([-1.5*10000 1.5*10000])
daspect([1 1 1])

% Info
legend('Initial Orbit', '', 'Initial Position', 'Final Orbit', '', 'Final position')
title('Overview')

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

% Esclusione manovra biellittica
%{
% % Manovra biellittica
% rpf = kepElf(1)*(1-kepElf(2));
% dv_vect = [];
% dt_3b_vect = [];
% rb = 8000:.01:9000;
% 
% for i = 1 : length(rb)
%     [dv1, dv2, dv3, thf, dt_3b] = biElliptic (kepEli(1) , kepEli(2), ...
%                                 kepElf(1) , kepElf(2), rb(i), 180);
%     dv_vect = [ dv_vect ; dv1+dv2+dv3];
%     dt_3b_vect = [ dt_3b_vect ; dt_3b ];
% end
% rt = 6378;
% 
% figure
% plot( rb , dt_3b_vect )
% xlabel ('rb')
% ylabel( 'dt')
% 
% dv_vant = 0;
% for i = 1 : length(dv_vect)
%     if (dv_vect(i) < dv_3) && (rb(i) > rt+100)
%         % disp('Vantaggioso e raggio ammissibile ')
%         if dv_vant == 0
%             dv_vant = dv_vect(i);
%             rb_vant = rb(i);
%         elseif dv_vect(i) < dv_vant
%             dv_vant = dv_vect(i);
%             rb_vant = rb(i);
%             i_vant = i;
%         end
%     end
% end
% 
% figure
% plot( rb , dv_vect )
% xlabel ('rb')
% ylabel( 'dv')
% yline( dv_3 , '--k')
% xline ( rt+100 , '--k')
% yline( dv_vant , '--r')
% % Biellittica dv di poco vantaggioso per certi valori di rb, ma svantaggiosa 
% % per il tempo (differenza di circa 6154s)
%}

% Attesa fino al punto finale
plotOrbitQuiver([kepElf(1) kepElf(2) kepElf(3) kepElf(4) kepElf(5) 0], mu, 10, kepElf(6))

% Tiro delle somme
dvstd = dv1 + dv2 + dv3;
fprintf('%cv complessivo procedura standard: %.2f km/s\n', 916, dvstd)
dtstd = dt1 + dt2 + dt23 + dt3;
fprintf('%ct complessivo procedura standard: %.0f s\n', 916, dtstd)

% Tutte le manovre sono eseguite alla prima posizione utile

Terra3d
xlim([-1.5*10000 1.5*10000])
ylim([-1.5*10000 1.5*10000])
zlim([-1.5*10000 1.5*10000])

legend('Init Pos', 'Fin Pos', 'Orb Init', 'Plane Changed', 'Periapsis Arg Changed', 'Shape Changed', 'Orb Fin')
title('Strategia standard')

% ---------- DECIDERE STANDARD SCRITTURA MANOVRA --------------------------

%% STRATEGIA 2 MAVORA Anomalia-Piano-Forma

% cambio anomalia -> cambio piano (causante un cambio di w) -> cambio forma

% ALLINEAMENTO ASSI ECCENTRICITA'

a_i = kepEli(1);
e_i = kepEli(2); 
i_i = kepEli(3);
OM_i = kepEli(4); 
om_i = kepEli(5); 
th_i = kepEli(6);

a_f = kepElf(1);
e_f = kepElf(2); 
i_f = kepElf(3);
OM_f = kepElf(4); 
om_f = kepElf(5); 
theta_f = kepElf(6);

figure
hold on
grid on
xlabel('X [km]')
ylabel('Y [km]')
zlabel('Z [km]')
set(gca, 'FontSize', 12)
plot3(r0(1), r0(2), r0(3), 'o', 'MarkerSize', 10, 'MarkerEdgeColor', 'r', 'LineWidth', 3)
plot3(rf(1), rf(2), rf(3), 'x', 'MarkerSize', 15, 'MarkerEdgeColor', 'r', 'LineWidth', 3)

om_st = om_f - (144.1217 - om_f); % anomalia del perigeo "strategico", il quale permette di ottenere
...in seguito al cambio di piano (nel corrispettivo punto di manovra) l'anomalia di perigeo richiesta per l'orbita finale.

[dv_1, thm ,thf1, dt_1 ] = changePerArg (a_i, e_i, om_i , om_st , th_i);
%[delta_T] = timeOfFlight (a_i,e_i,th_ir,thm);

plotOrbitQuiver([a_i , e_i , i_i , OM_i , om_i , th_i ], mu, 20, thm)  % tratto 1
hold on

% CAMBIO DI PIANO (INCLINAZIONE + ASCENSIONE RETTA DEL NODO ASCENDENTE)

[dv_2, wf , thf2, dt2] = changeOrbPlane (a_i, e_i, i_i, OM_i, om_st, i_f, OM_f, thf1);

plotOrbitQuiver([a_i , e_i , i_i , OM_i , om_st , thf1 ], mu, 5 , thf2)  % tratto 2
hold on
plotOrbitQuiver([a_i , e_i , i_f , OM_f , wf , thf2 ], mu, 2 , 180 )  % tratto 3

% Tempo di trasferimento dal punto di cambio a piano (thf2) al punto di cambio forma (apogeo: 180°)
dt3 = flightTime (a_i, e_i, thf2, 180);

hold on

% CAMBIO FORMA
% 1) apocentro -> pericentro
[ delta_v31 , delta_t41 , a_t1 , e_t1] = changeOrbitShape(a_i , e_i , wf , a_f , e_f , wf , 1);

% 2) pericentro -> apocentro
%[ delta_v32 , delta_t42 , a_t2 , e_t2] = changeOrbitShape(a_i , e_i , wf , a_f , e_f , wf , 2);
% NB: la seconda opzione sul cambio di forma richiede un tempo di
... trasferimento molto maggiore 
    
plotOrbitQuiver([a_t1 , e_t1 , i_f , OM_f , wf , 180 ], mu, 20, 0) % tratto 4  % da rivedere

hold on

plotOrbitQuiver([a_f , e_f , i_f , OM_f , wf , 0 ], mu, 5, theta_f) % tratto 5

% Tempo di trasferimento dal perigeo della nuova orbita al punto d'arrivo (theta_f)
dt5 = flightTime (a_f, e_f, 0 , theta_f);

hold on

Terra3d
% 
% plotOrbit(kepEli, mu, .1)
% plot3(r0(1), r0(2), r0(3), 'o', 'MarkerSize', 10, 'MarkerEdgeColor', 'r', 'LineWidth', 3);
% 
% plotOrbit(kepElf, mu, .1)
% plot3(rf(1), rf(2), rf(3), 'x', 'MarkerSize', 15, 'MarkerEdgeColor', 'r', 'LineWidth', 3);

legend('Init Pos', 'Fin Pos', 'Orb Init', 'Periapsis Arg Changed','Plane Changed', 'Shape Changed', 'Orb Fin')
title('Trasferimento APF')

% COSTO TOTALE E TEMPO DI TRASFERIMENTO DELLA MISSIONE

dv_TOT = abs(dv_1) + abs(dv_2) + abs(delta_v31);                            % 2.3491 km/s
dt_TOT_sec = dt_1 + dt2 + dt3 + delta_t41 + dt5;                            % 10335 sec
dt_TOT_ore = (dt_TOT_sec)/3600;                                             % 2.8706 ore ~= 2 ore e 52 minuti

fprintf('%cv complessivo procedura Anomalia-Piano-Forma: %.2f km/s\n', 916, dv_TOT)
fprintf('%cv complessivo procedura Anomalia-Piano-Forma: %.2f s\n', 916, dt_TOT_sec)



