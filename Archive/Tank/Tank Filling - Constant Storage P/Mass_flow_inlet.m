function mdot_in = Mass_flow_inlet(P_liq,P_vap,T_tank,rho_liq,rho_vap,x)
%
global opts

S_inlet=opts.S_inlet;

cd_inlet=opts.cd_inlet;%Pressure drop coefficient

P_average=(P_vap);

deltaP=opts.P_storage_tank-P_average;

if deltaP<=0
    deltaP=0;
end

v_inlet= cd_inlet * sqrt(2*deltaP/rho_liq);%From Bernouilli

mdot_in=rho_liq*S_inlet*v_inlet;

end

    