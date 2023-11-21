function [delta_v_tot , delta_t , a_t , e_t] = changeOrbitShape(a_i , e_i , om_i , a_f , e_f , om_f , option)

mu = 398600;

% Parametri orbita iniziale
r_pi = a_i*(1-e_i);
r_ai = a_i*(1+e_i);
p_i = a_i*(1-e_i^2);
v_ia = sqrt(mu/p_i) * (1-e_i);
v_ip = sqrt(mu/p_i) * (1+e_i);

% Parametri orbita finale
r_pf = a_f*(1-e_f);
r_af = a_f*(1+e_f);
p_f = a_f*(1-e_f^2);
v_fa = sqrt(mu/p_f) * (1-e_f);
v_fp = sqrt(mu/p_f) * (1+e_f);

if om_i == om_f
    if option == 1
        % Parametri orbita di trasferimento (apocentro -> pericentro)
        a_t = (r_pf + r_ai) / 2;
        e_t = (r_ai - r_pf) / (r_ai + r_pf);
        p_t = a_t*(1-e_t^2);
        v_ta = sqrt(mu/p_t) * (1-e_t);
        v_tp = sqrt(mu/p_t) * (1+e_t);
        % Calcolo dei delta_v (apocentro -> pericentro)
        delta_vi = abs(v_ta - v_ia);
        delta_vf = abs(v_fp - v_tp);
    else
        % Parametri orbita di trasferimento (pericentro -> apocentro)
        a_t = (r_pi + r_af) / 2;
        e_t = (r_af - r_pi) / (r_af + r_pi);
        p_t = a_t*(1-e_t^2);
        v_ta = sqrt(mu/p_t) * (1-e_t);
        v_tp = sqrt(mu/p_t) * (1+e_t);
       
        % Calcolo dei delta_v (pericentro -> apocentro)
        delta_vi = abs(v_tp - v_ip);
        delta_vf = abs(v_fa - v_ta);
    end
elseif abs(om_i-om_f) == 180
    if option == 1
        % Parametri orbita di trasferimento (pericentro -> pericentro)
        a_t = (r_pi + r_pf) / 2;
        e_t = (r_pf - r_pi) / (r_pf + r_pi);
        p_t = a_t*(1-e_t^2);
        v_ta = sqrt(mu/p_t) * (1-e_t);
        v_tp = sqrt(mu/p_t) * (1+e_t);
       
        % Calcolo dei delta_v (pericentro -> pericentro)
        delta_vi = abs(v_ip - v_tp);
        delta_vf = abs(v_fp - v_ta);
    else
        % Parametri orbita di trasferimento (apocentro -> apocentro)
        a_t = (r_ai + r_af) / 2;
        e_t = (r_af - r_ai) / (r_af + r_ai);
        p_t = a_t*(1-e_t^2);
        v_ta = sqrt(mu/p_t) * (1-e_t);
        v_tp = sqrt(mu/p_t) * (1+e_t);
       
        % Calcolo dei delta_v (apocentro -> apocentro)
        delta_vi = abs(v_tp - v_ia);
        delta_vf = abs(v_ta - v_fa);
    end
end

% Costo totale
delta_v_tot = delta_vf + delta_vi;

% Periodo
delta_t = pi*sqrt(a_t^3 / mu); 





