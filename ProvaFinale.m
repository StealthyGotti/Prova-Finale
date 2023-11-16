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

%% Manovra standard
% Posizione iniziale - caratterizzata 
% Attesa fino al punto di manovra, seguito da un cambio di piano
% Più si è distanti dal fuoco e meno costa --> punto di manovra == apocentro

[dv_1, wi_1, thf, dt_1] = changeOrbPlane (kepEli(1), kepEli(2), kepEli(3), kepEli(4), kepEli(5), ...
                        kepElf(3), kepElf(4), kepEli(6));
fprintf( '\n dv_1: %.4f \n dt_1: %.2f\n' , dv_1 , dt_1)

% Attesa fino al punto di manovra, cambio di forma dell'orbita
dt_23 = flightTime( kepEli(1) , kepEli(2) , thf , 180);
fprintf( '\n dt_23: %.2f\n' , dt_23)         % tempo per arrivare all'apogeo

% Manovra bitangente
[dvi, dvf, thf, dt_3] = biTangent (kepEli(1) , kepEli(2), kepElf(1) , kepElf(2), 180);
dv_3 = dvi + dvf;
fprintf( '\n dv_3: %.4f \n dt_3: %.2f\n' , dv_3 , dt_3)

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

% Attesa fino al punto di arrivo 
dt_34 = flightTime( kepElf(1) , kepElf(2) , thf , kepElf(6));
fprintf( '\n dt_34: %.2f\n' , dt_34)



