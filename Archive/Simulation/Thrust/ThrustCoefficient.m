function Cs = ThrustCoefficient(Pe,Pcc,Patm,At,opts)
%THRUSTCOEFFICIENT

gam = opts.gamma;
Ae = opts.A_exit;
P0 = opts.P_atm_sl;

Cs = sqrt(2*gam^2/(gam-1)*(2/(gam+1))^((gam+1)/(gam-1))*(1-(Pe./Pcc).^((gam-1)/gam)))+(Pe-Patm)/P0*Ae/At;

end

