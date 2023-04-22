function F_tank = Tank_temperature_finder_fct_filling_3ph(U,m,T,V)
%TANK_TEMPERATURE_FINDER_FCT : Function we try to find the 0 so that we
%have thermodynamical equilibrium

    global opts
    
    
    % Spline liquid density (kg/m^3)
    rho_liq = fnval(opts.RhoL_T_NO2_spline,T);
    
    % Spline vapor density (kg/m^3)
    rho_vap = fnval(opts.RhoG_T_NO2_spline,T);
        
    x=x_vapor_filling_temperature(U,m,T);
    
    F_tank = V-(m.*((1-x)./rho_liq+x./rho_vap));
    
end

