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
% text(r0(1)+100, r0(2)+100, r0(3)+100, 'i', 'FontSize', 16, 'FontWeight', 'bold')
% text(rf(1)+100, rf(2)+100, rf(3)+100, 'f', 'FontSize', 16, 'FontWeight', 'bold')
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
[hr, min, sec] = time2esa(dtstd);
fprintf('%ct complessivo procedura standard: %.0f s = %.0f hr %.0f min %.0f s\n', 916, dtstd, hr, min, sec)

% Tutte le manovre sono eseguite alla prima posizione utile

Terra3d
xlim([-1.5*10000 1.5*10000])
ylim([-1.5*10000 1.5*10000])
zlim([-1.5*10000 1.5*10000])

legend('Init Pos', 'Fin Pos', 'Orb Init', 'Plane Changed', 'Periapsis Arg Changed', 'Shape Changed', 'Orb Fin')
title('Strategia standard')

%% MANOVRA

%% MANOVRA

%% MANOVRA BIELLITTICA

% si procede con un'analisi della convenienza al variare del raggio di apocentro della biellittica

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

% ESEMPIO (rb = 10000 km, no skip)
[dvbi, dtbi, kepElt1, kepElt2, thm, thfb, axis] = biEllipticChangeOrb (kepEli, kepElf, 10000);
plotOrbitQuiver(kepEli, mu, 5, thm)
plotOrbitQuiver([kepElt1(1) kepElt1(2) kepElt1(3) kepElt1(4) kepElt1(5) 0], mu, 5, 180) 
plotOrbitQuiver([kepElt2(1) kepElt2(2) kepElt2(3) kepElt2(4) kepElt2(5) 0], mu, 5, 180)
plotOrbitQuiver([kepElf(1) kepElf(2) kepElf(3) kepElf(4) kepElf(5) thfb], mu, 5, kepElf(6))
% plotOrbit(kepEli, mu, .1)
% plotOrbit(kepElt1, mu, .1)
% plotOrbit(kepElt2, mu, .1)
% plotOrbit(kepElf, mu, .1)
plot3(1e4*[-axis(1) axis(1)], 1e4*[-axis(2) axis(2)], 1e4*[-axis(3) axis(3)], 'k--')
Terra3d

fprintf('%cv complessivo procedura biellittica: %.2f km/s\n', 916, dvbi)
[hr, min, sec] = time2esa(dtbi);
fprintf('%ct complessivo procedura biellittica: %.0f s = %.0f hr %.0f min %.0f s\n', 916, dtbi, hr, min, sec)

legend('Init Pos', 'Fin Pos', 'Orb Init', 'First Arch', 'Second Arch', 'Orb Fin', 'Man Axis')
title('Strategia biellittica')

rbmin = 7000;
rbmax = 100000;
dvb = zeros(1,length(rbmin:100:rbmax));
dtb = zeros(1,length(rbmin:100:rbmax));
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
plot(rb, dvb)
xlabel('rb [km]')
ylabel('dv [km/s]')
title('Velocity')
grid on
figure
set(gca, 'FontSize', 12)
plot(rb, dtb/3600)
xlabel('rb [km]')
ylabel('dt [hr]')
title('Time')
grid on

% DA VERIFICARE MEGLIO (OCCHIO)
% valore minimo senza skip (prima manovra disponibile): 2.02 km/s @ 9300 km
% valore minimo con skip (seconda manovra disponibile): 1.75 km/s @ 14000 km