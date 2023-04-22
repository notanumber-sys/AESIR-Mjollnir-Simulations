function mdot_out = Mass_flow_outlet(P_tank,T_tank,rho_vap)
%Return the mass flow outlet through the vent hole
global opts

S_outlet=opts.S_outlet;%m2

cd_outlet=opts.cd_outlet;   %Pressure drop coefficient assumed to be negligible
P_atm=opts.P_atm_sl;%Pa
gamma_ox = opts.gamma_ox;
r_NO2 = opts.r_ox;

deltaP_outlet=P_tank-P_atm;%Pa

if deltaP_outlet<=0
    deltaP_outlet=0;
end

Wdot_star_out = 1000*cd_outlet*S_outlet*P_tank/sqrt(T_tank)*sqrt(gamma_ox/r_NO2)*sqrt((2/(gamma_ox+1))^((gamma_ox+1)/(gamma_ox-1)));

Wdot_out=cd_outlet * S_outlet * sqrt(2*deltaP_outlet*rho_vap);    %in kg/s


if Wdot_out > Wdot_star_out
    mdot_out = Wdot_star_out;
else
    mdot_out = Wdot_out;
end


end
