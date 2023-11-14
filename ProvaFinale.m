% PROVA FINALE IAMS

mu = 398600;

% Orbita iniziale
r0 = [-8205.9652; -4682.7991; 2382.4314];
v0 = [1.8330; -5.5360; -2.2630];
[ai, ei, ii, OMi, omi, thi] = car2kep(r0, v0, mu);
kepEli = [ai, ei, ii, OMi, omi, thi];
disp(kepEli)
justPlotOrbit(kepEli, mu, .01)

% Orbita finale
kepElf = [11860.0000, 0.2614, 0.5352, 0.8005, 2.3120, 0.9719];
disp(kepElf)
addPlotOrbit(kepElf, mu, .01)

% PROBLEMI PIÙ GROSSI ATTUALMENTE:
% 
% - gestire deg/rad
% - buttare giù lista di possibili sequenze di manovre
%   (tutti i parametri cambiano)
% - sapere come consegnare codici Matlab®
