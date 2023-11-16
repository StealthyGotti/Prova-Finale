% PROVA FINALE

mu = 398600;

% Orbita iniziale
r0 = [-8205.9652; -4682.7991; 2382.4314];
v0 = [1.8330; -5.5360; -2.2630];
[kepEli(1), kepEli(2), kepEli(3), kepEli(4), kepEli(5), kepEli(6)] = car2kep(r0, v0, mu);
fprintf('Parametri kepleriani orbita iniziale: [%.2f %.4f %.2f %.2f %.2f %.2f]\n', kepEli(1), kepEli(2), kepEli(3), kepEli(4), kepEli(5), kepEli(6))
justPlotOrbit(kepEli, mu, .1)

% Orbita finale
kepElf = [11860.0000, 0.2614, rad2deg(0.5352), rad2deg(0.8005), rad2deg(2.3120), rad2deg(0.9719)];
fprintf('Parametri kepleriani orbita finale: [%.2f %.4f %.2f %.2f %.2f %.2f]\n', kepElf(1), kepElf(2), kepElf(3), kepElf(4), kepElf(5), kepElf(6))
addPlotOrbit(kepElf, mu, kepElf(6)+360, .1)
[rf, ~] = kep2car(kepElf(1), kepElf(2), kepElf(3), kepElf(4), kepElf(5), kepElf(6), mu);
plot3(rf(1), rf(2), rf(3), 'x', 'MarkerSize', 15, 'MarkerEdgeColor', 'r', 'LineWidth', 3)

% PROBLEMI PIÙ GROSSI ATTUALMENTE:
% 
% - gestire deg/rad ---------------------------------------------------- OK
% - buttare giù lista di possibili sequenze di manovre
%   (tutti i parametri cambiano, maremma caleidoscopica)
% - sapere come consegnare codici Matlab®

%% Manovra standard
% Posizione iniziale - caratterizzata 
% Attesa fino al punto di manovra, seguito da un cambio di piano
% Più si è distanti dal fuoco e meno costa --> punto di manovra == apocentro (no, scherzone)

% Attesa fino al punto di manovra, cambio piano
[dv1, w1, th1, dt1] = changeOrbPlane (kepEli(1), kepEli(2), kepEli(3), kepEli(4), kepEli(5), kepElf(3), kepElf(4), kepEli(6));
addPlotOrbit(kepEli, mu, th1, .01)

% Attesa fino al punto di manovra, cambio di anomalia del pericentro
[dv2, th2, th3, dt2] = changePerArg ( kepEli(1), kepEli(2), w1 , kepElf(5) , th1);
addPlotOrbit([kepEli(1) kepEli(2) kepElf(3) kepElf(4) w1 th1], mu, th2, .01)

% Attesa fino al punto di manovra di cambio di forma dell'orbita
dt23 = flightTime( kepEli(1) , kepEli(2) , th3 , 180); % tempo per arrivare all'apogeo
addPlotOrbit([kepEli(1) kepEli(2) kepElf(3) kepElf(4) kepElf(5) th3], mu, 180, .01)

% Manovra bitangente all'apogeo, cambio di forma dell'orbita
[dvi, dvf, thf, dt3, at, et] = biTangent (kepEli(1) , kepEli(2), kepElf(1) , kepElf(2), 180);
dv3 = dvi + dvf;
addPlotOrbit([at et kepElf(3) kepElf(4) kepElf(5) 180], mu, 0, .01)

% Attesa fino al punto finale
addPlotOrbit([kepElf(1) kepElf(2) kepElf(3) kepElf(4) kepElf(5) 0], mu, kepElf(6), .01)

title('Strategia standard')