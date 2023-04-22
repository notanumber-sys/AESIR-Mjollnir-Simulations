function x_vapor = x_vapor_filling_pressure(U_tot,m_NO2,P_vap)
%This function computes the value of the vapor factor tanks to the
%temperatre inside the tank
    global opts
    
    %Coolprop u(T) liquid at saturation (J/kg)
    u_liq = fnval(opts.UL_P_NO2_spline,P_vap/10^6)*10^3;
%     py.CoolProp.CoolProp.PropsSI('U','P',P_vap,'Q', 0,'NitrousOxide');
    
    %Coolprop u(T) vapor at saturation (J/kg)
    u_vap = fnval(opts.UG_P_NO2_spline,P_vap/10^6)*10^3;
%     py.CoolProp.CoolProp.PropsSI('U','P',P_vap,'Q', 1,'NitrousOxide');
    
    
    x_vapor=((U_tot./m_NO2)-u_liq)./(u_vap-u_liq);

end

