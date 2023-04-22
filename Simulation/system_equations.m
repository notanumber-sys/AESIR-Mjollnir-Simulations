function [state_vector, m_tot, h_liq, h_gas, h_air_ext] = system_equations(~, u)

    global opts
    
    m_ox = u(1);                % The oxidizer mass.
    U_tank_total = u(2);        % The total energy inside the tank.
    T_tank_wall = u(3);         % The tank wall temperature.
    r_cc = u(4);                % The radius of the combustion chamber.
    r_throat = u(5);            % The throat radius.
    P_cc = u(6);                % The pressure in the combustion chamber.
    x = u(7);                   % The position on the x-axis (m).
    y = u(8);                   % The position on the y-axis (m).
    dxdt = u(9);                % The velocity along the x-axis (m/s).
    dydt = u(10);               % The velocity along the y-axis (m/s).
    
    if y < 0
        y = 0;  % Fix atmoscoesa warnings.
    end
    
    A_t = pi * r_throat.^2;                  % Compute the throat area (m^2).
    v_rocket = sqrt(dxdt^2 + dydt^2);        % Compute total velocity.
    
    % Get the temperature (K), speed of sound (m/s), pressure (Pa), and density (kg/m^3) at height y.
    [T_ext_COESA, speed_of_sound, P_ext, rho_ext] = atmoscoesa(y);
    T_ext = T_ext_COESA - opts.dT_ext;
    
    m_wall = opts.rho_alu * pi * opts.L_tank * (opts.D_ext_tank^2 - opts.D_int_tank^2) / 4;     % Compute the mass of the tank wall (density * pi * length * (external_r^2 - internal_r^2)).
    c_wall = opts.alu_thermal_capacity; 
    gamma = opts.gamma_combustion_products;
    Mw = opts.molecular_weight_combustion_products;
    R = opts.R; 
    
    m_fuel = opts.rho_fuel * pi * opts.L_fuel * (opts.D_cc_int^2 / 4 - r_cc^2);     % Compute the fuel mass (density * pi * length * (fuel_r^2 - cc_r^2)).
    
    T_tank = tank_temperature(U_tank_total, m_ox);      % Compute the tank temperature.
    x_vap = x_vapor(U_tank_total, m_ox, T_tank);        % Compute the massic vapor ratio.
    rho_liq = fnval(opts.RhoL_T_N2O_spline, T_tank);    % Density for liquid N2O (kg/m^3).
    rho_vap = fnval(opts.RhoG_T_N2O_spline, T_tank);    % Density for vapor N2O (kg/m^3).
    
    remaining_ox = (1 - x_vap) * m_ox / (rho_liq * opts.V_tank) * 100;      % Compute the remaining percentage of liquid oxidizer volume in the tank, recall that volume = mass / density.
    
    P_N2O = fnval(opts.Psat_N2O_spline, T_tank) * 10^6;     % Get saturation pressure of N2O at this tank temperature.
    P_tank = P_N2O;     % Key assumption (I think): Tank pressure is at the point of N2O saturation.
     
    mf_ox = mass_flow_oxidizer(T_tank, P_tank, P_cc);   % Compute oxidizer mass flow.
    A_port = pi * r_cc^2;                               % Compute port area.
    G_o = mf_ox / A_port;                               % Compute oxidizer mass velocity (see Sutton, 2017, p. 602).
    mf_fuel = mass_flow_fuel(G_o, r_cc);                % Compute fuel mass flow.
    OF = mf_ox / mf_fuel;                               % Compute O/F ratio.
    mf_throat = mass_flow_throat(P_cc, OF, A_t);        % Compute throat mass flow.
    
    [Qdot_w_t, h_liq, h_gas] = heat_flux_wall_tank(P_N2O, x_vap, T_tank_wall, T_tank);  % Compute thermal heat flux from the tank wall to the interior.
    [Qdot_ext_w, h_air_ext] = heat_flux_ext_wall(v_rocket, T_ext, P_ext, T_tank_wall);  % Compute thermal heat flux from the exterior to the tank wall.
    
    h_outlet = py.CoolProp.CoolProp.PropsSI('H', 'P', P_tank, 'T|liquid', T_tank, 'NitrousOxide');  % Get mass specific enthalpy of N2O.
    
    V_cc = pi * (opts.D_cc_int^2 / 4 * opts.L_cc - (opts.D_cc_int^2 / 4 - r_cc^2) * opts.L_fuel);    % Compute volume of the combustion chamber (total_volume - fuel_volume).
    
    c_star = interp1q(opts.OF_set, opts.c_star_set, OF);                            % Get the characteristic velocity of paraffin with N2O at the current O/F ratio.
    RTcc_Mw = gamma * (2 / (gamma + 1))^((gamma + 1) / (gamma - 1)) * c_star^2;     % Compute the ratio R * T_cc / Mw (see Sutton, 2017, p. 63).
    T_cc = RTcc_Mw * Mw / R;                                                        % Compute the combustion chamber temperature.
    
    % Equations for the tank model.
    dmtotaldt = -mf_ox;
    dUtotaldt = -mf_ox * h_outlet + Qdot_w_t;
    dTwalldt = (Qdot_ext_w - Qdot_w_t) / (m_wall * c_wall);
    drdt = opts.a * (G_o)^opts.n;
    dP_ccdt = (mf_fuel + mf_ox - mf_throat) * RTcc_Mw / V_cc;
    
    
    % Compute exhaust quantities.
    M_ex = exhaust_Mach(A_t);
    P_ex = exhaust_pressure(P_cc, P_ext, M_ex);
    v_ex = exhaust_speed(T_cc, P_ex, P_cc);
    
    if remaining_ox <= 0
        % Tank is empty (thrust and oxidizer mass are set to zero).
        m_tot = m_fuel + opts.dry_mass;     % Compute total mass.
        [d2xdt2, d2ydt2] = eq_of_motion(0, 0, m_fuel, y, dxdt, dydt, speed_of_sound, rho_ext);
        if y <= 0
            % The rocket has landed/crashed.
            dxdt = 0;
            dydt = 0;
            d2xdt2 = 0;
            d2ydt2 = 0;
        end
        state_vector = [0; 0; 0; 0; 0; 0; dxdt; dydt; d2xdt2; d2ydt2];
    else
        F = opts.combustion_efficiency * thrust(mf_throat, v_ex, P_ext, P_ex);   % Compute thrust.
        m_tot = m_ox + m_fuel + opts.dry_mass;      % Compute total mass.
        [d2xdt2, d2ydt2] = eq_of_motion(F, m_ox, m_fuel, y, dxdt, dydt, speed_of_sound, rho_ext);
        
        state_vector = [dmtotaldt; dUtotaldt; dTwalldt; drdt; opts.dr_thdt; dP_ccdt; dxdt; dydt; d2xdt2; d2ydt2];
    end
    
    if remaining_ox < opts.remaining_ox - 5
        opts.remaining_ox = opts.remaining_ox - 5;
        disp("Tank: " + round(remaining_ox) + "% full")
    end
end

