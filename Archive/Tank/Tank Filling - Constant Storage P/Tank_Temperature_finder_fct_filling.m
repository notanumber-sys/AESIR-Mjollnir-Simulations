function F_tank = Tank_Temperature_finder_fct_filling(U_tot,m_NO2,T)
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
    
    x=x_vapor_filling(U_tot,m_NO2,T);
    
    F_tank = V_tank-m_NO2.*((1-x)./rho_liq+x./rho_vap);


end

