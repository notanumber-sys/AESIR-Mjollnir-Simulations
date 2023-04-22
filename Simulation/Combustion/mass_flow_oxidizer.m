function mf_ox = mass_flow_oxidizer(T_tank, P_tank, P_cc)
    %MASS_FLOW_FUEL calculates the mass flow of the fuel
    global opts
    
    if strcmp(opts.model, 'Dyer')
        [P_cc_range, mf_crit] = critical_mf_Dyer(P_tank, T_tank);
    else
        % Use Moody by default.
        [P_cc_range, mf_crit] = critical_mf_Moody(P_tank, T_tank, opts.Cd);
    end
    
    mf_ox = interp1(P_cc_range, mf_crit, P_cc);
end

