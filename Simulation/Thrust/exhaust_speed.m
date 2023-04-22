function v_e = exhaust_speed(T_cc, P_ex, P_cc)
% Compute exhaust speed using de Laval nozzle formula (see Sutton, 2017, p. 52 or https://en.wikipedia.org/wiki/De_Laval_nozzle).

global opts

R = opts.R;
M = opts.molecular_weight_combustion_products;
gamma = opts.gamma_combustion_products;

v_e = sqrt((T_cc * R / M) * 2 * gamma / (gamma - 1) * (1 - (P_ex / P_cc)^((gamma - 1) / gamma)));
end
