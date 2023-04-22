function [T, x] = Tank_temperature_filling_3ph(U,m,V)
% TANK_TEMPERATURE : finding the zero of the thermodynamic equilibrium function to get internal temp of the tank

    global opts
    
    if m==0 || V==0
        T=opts.T_ext;
    else
        T = fzero(@(T_unknown) Tank_temperature_finder_fct_filling_3ph(U,m,T_unknown,V), [191 305]);
    end
    
    x=min(1,max(0,x_vapor_filling_temperature(U,m,T)));
    
end

