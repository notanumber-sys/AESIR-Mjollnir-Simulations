function T_tank = tank_temperature(U_total,m_total)
%TANK_TEMPERATURE : finding the zero of the thermodynamic equilibrium function to get internal temp of the tank
%disp(U_total)
%disp(m_total)
T_tank = fzero(@(T_unknown) Tank_Temperature_finder_fct(U_total,m_total,T_unknown), [183, 309.51]);

end

function F_tank = Tank_Temperature_finder_fct(U_tot,m_tot,T)
%TANK_TEMPERATURE_FINDER Function is the function that temperature must
%verify
%To find the tank temperature, the model will try to find T such that
%Tank_Temperature_finder_fct(Utot,mtot,T)=0 (Utot is fixed at each step)

    global opts
    
    %Coolprop liquid density (kg/m^3)
    rho_liq = py.CoolProp.CoolProp.PropsSI('D','T',T,'Q', 0,'NitrousOxide');
    
    %Coolprop vapor density (kg/m^3)
    rho_vap = py.CoolProp.CoolProp.PropsSI('D','T',T,'Q', 1,'NitrousOxide');
    
    V_tank=opts.V_tank;
    
    x=x_vapor(U_tot,m_tot,T);
    
    F_tank = V_tank-m_tot.*((1-x)./rho_liq+x./rho_vap);


end
