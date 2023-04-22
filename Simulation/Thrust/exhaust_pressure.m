function P_ex = exhaust_pressure(P_cc, P_ext, M_ex)
% Compute the exhaust pressure (see Sutton, 2017, p. 49).

global opts

gamma = opts.gamma_combustion_products;

if P_cc == P_ext
    P_ex = P_ext;
else
    P_ex = P_cc * (1 + (gamma - 1) * M_ex^2 / 2)^(gamma / (1 - gamma));
end
end

