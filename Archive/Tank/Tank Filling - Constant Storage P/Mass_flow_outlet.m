function mdot_out = Mass_flow_outlet(P_vap,T_tank,rho_vap)
%Return the mass flow outlet through the vent hole
global opts

S_outlet=opts.S_outlet;%m2

cd_outlet=1;%Pressure drop coefficient assumed to be negligible
P_atm=opts.P_atm_sl;%Pa

deltaP_outlet=P_vap-P_atm;%Pa

if deltaP_outlet<=0
    deltaP_outlet=0;
end

v_outlet= cd_outlet * sqrt(2*deltaP_outlet/rho_vap);%From Bernouilli in m/s

mdot_out=rho_vap*S_outlet*v_outlet;%kg/s

end
