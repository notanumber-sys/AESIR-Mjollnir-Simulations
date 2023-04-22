function x_vapor = x_vapor(U_tot, m_tot, T)
    % Compute the massic vapor ratio at each time step.
    u_liq = py.CoolProp.CoolProp.PropsSI('U', 'T', T, 'Q', 0, 'NitrousOxide');      % Specific internal energy for liquid N2O (J/kg).
    u_vap = py.CoolProp.CoolProp.PropsSI('U', 'T' ,T, 'Q', 1, 'NitrousOxide');      % Specific internal energy for vapor N2O (J/kg).

    % Note that the following equation equals one if and only if the specific internal energy of whatever is in the tank equals the
    % specific internal energy for vapor N2O, and zero if it equals that for liquid.
    x_vapor = ((U_tot ./ m_tot) - u_liq) ./ (u_vap - u_liq);  
end
