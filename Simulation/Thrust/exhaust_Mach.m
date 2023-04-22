function M_ex = exhaust_Mach(A_t)
% Compute the exhaust Mach number.

M_ex_zero = fzero(@(M) exhaust_Mach_fct(M, A_t), 2);
M_ex = max(0, M_ex_zero);
end

function f = exhaust_Mach_fct(M_ex, A_t)
% Equality f(M_ex) = 0 that we use to find the Mach number (see Sutton, 2017, p. 60).

global opts

A_ex = opts.A_exit;
gamma = opts.gamma_combustion_products;

f = 1 / M_ex * (2 / (gamma + 1) * (1 + (gamma - 1) * M_ex^2 / 2))^((gamma + 1) / (2 * (gamma - 1))) - A_ex / A_t;
end
