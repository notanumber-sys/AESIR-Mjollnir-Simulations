function x_vapor = x_vapor_filling_temperature(U_tot,m_NO2,T_tank)
%This function computes the value of the vapor factor tanks to the
%temperatre inside the tank
    

    global opts
    
    %Coolprop u(T) liquid at saturation (J/kg)
    u_liq = fnval(opts.UL_T_NO2_spline,T_tank)*10^3;
%     py.CoolProp.CoolProp.PropsSI('U','T',T_tank,'Q', 0,'NitrousOxide');
    
    %Coolprop u(T) vapor at saturation (J/kg)
    u_vap = fnval(opts.UG_T_NO2_spline,T_tank)*10^3;
%     py.CoolProp.CoolProp.PropsSI('U','T',T_tank,'Q', 1,'NitrousOxide');
    
    
    x_vapor=((U_tot./m_NO2)-u_liq)./(u_vap-u_liq);

end

