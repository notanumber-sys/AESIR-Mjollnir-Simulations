function F = thrust(mf_throat, v_ex, P_ext, P_ex)
% Compute thrust (see Sutton, 2017, p. 33).

global opts

A_ex = opts.A_exit;
F = mf_throat * v_ex + (P_ex - P_ext) * A_ex;
end

