% PROVA FINALE

mu = 398600;

% Orbita iniziale
r0 = [-8205.9652; -4682.7991; 2382.4314];
v0 = [1.8330; -5.5360; -2.2630];
[kepEli(1), kepEli(2), kepEli(3), kepEli(4), kepEli(5), kepEli(6)] = car2kep(r0, v0, mu);
fprintf('Parametri kepleriani orbita iniziale: [%.2f %.4f %.2f %.2f %.2f %.2f]\n', kepEli(1), kepEli(2), kepEli(3), kepEli(4), kepEli(5), kepEli(6))
justPlotOrbit(kepEli, mu, 1)

% Orbita finale
kepElf = [11860.0000, 0.2614, rad2deg(0.5352), rad2deg(0.8005), rad2deg(2.3120), rad2deg(0.9719)];
fprintf('Parametri kepleriani orbita finale: [%.2f %.4f %.2f %.2f %.2f %.2f]\n', kepElf(1), kepElf(2), kepElf(3), kepElf(4), kepElf(5), kepElf(6))
addPlotOrbit(kepElf, mu, 1)

% PROBLEMI PIÙ GROSSI ATTUALMENTE:
% 
% - gestire deg/rad ---------------------------------------------------- OK
% - buttare giù lista di possibili sequenze di manovre
%   (tutti i parametri cambiano, maremma caleidoscopica)
% - sapere come consegnare codici Matlab®

% Posizione iniziale - caratterizzata 
% Attesa fino al punto di manovra, seguito da un cambio di piano
% Più si è distanti dal fuoco e meno costa --> punto di manovra == apocentro

dt_1 = flightTime( kepEli(1) , kepEli(2) , kepEli(6) , 180);    %t per arrivare in apocentro

[dv, wf, thf, dt] = changeOrbPlane (kepEli(1), kepEli(2), kepEli(3), kepEli(4), kepEli(5), ...
                        kepElf(3), kepElf(4), kepEli(6));
fprintf( '\n dv: %.4f \ndt: %.2f\n' , dv , dt+dt_1)
