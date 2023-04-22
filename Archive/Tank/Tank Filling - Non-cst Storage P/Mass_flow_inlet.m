function mdot_in = Mass_flow_inlet(P_tank,P_storage,T_storage)
%
global opts

S_inlet=opts.S_inlet;
gamma_ox = opts.gamma_ox;
r_NO2 = opts.r_ox;
cd_inlet=opts.cd_inlet;         %Pressure drop coefficient

Cf = 0.82;

rho_liq = fnval(opts.RhoL_T_NO2_spline,T_storage);
deltaP=P_storage-P_tank;

if deltaP<=0
    deltaP=0;
    disp("deltaP neg")
end

% Wdot_star = cd_inlet*S_inlet*P_storage/sqrt(T_storage)*sqrt(gamma_ox/r_NO2)*sqrt((2/(gamma_ox+1))^((gamma_ox+1)/(gamma_ox-1)));

% Wdot_in=cd_inlet*S_inlet*sqrt(2*deltaP*rho_liq);    %in kg/s
mdot_in=cd_inlet*S_inlet*sqrt(2*deltaP*rho_liq);

% if Wdot_in > Wdot_star
%     mdot_in = Wdot_star;
% else
%     mdot_in = Wdot_in;
% end

end

    