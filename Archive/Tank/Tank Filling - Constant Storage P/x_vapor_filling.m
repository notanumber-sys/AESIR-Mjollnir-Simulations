function x_vapor = x_vapor_filling(U_tot,m_NO2,T)
%This function computes the value of the vapor factor tanks to the
%temperatre inside the tank

    %Coolprop u(T) liquid at saturation (J/kg)
    u_liq = py.CoolProp.CoolProp.PropsSI('U','T',T,'Q', 0,'NitrousOxide');
    
    %Coolprop u(T) vapor at saturation (J/kg)
    u_vap = py.CoolProp.CoolProp.PropsSI('U','T',T,'Q', 1,'NitrousOxide');
    
    
    x_vapor=max(min(((U_tot./m_NO2)-u_liq)./(u_vap-u_liq),1),0);

end

