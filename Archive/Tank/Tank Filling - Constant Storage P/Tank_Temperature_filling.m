function T_tank = Tank_Temperature_filling(U_total,m_NO2)
%TANK_TEMPERATURE : finding the zero of the thermodynamic equilibrium function to get internal temp of the tank
% disp(U_total)
% disp(m_total)
global opts

if m_NO2==0
    T_tank=opts.T_ext;
else
    T_tank = fzero(@(T_unknown) Tank_Temperature_finder_fct_filling(U_total,m_NO2,T_unknown), [183, 309.51]);
end

end

