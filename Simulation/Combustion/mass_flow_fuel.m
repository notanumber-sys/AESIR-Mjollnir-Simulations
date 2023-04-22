function m_dot_fuel = mass_flow_fuel(G_ox, r_fuel)
    % Calculate fuel mass flow (see Sutton, 2017, p. 606).
    global opts
    
    rho_fuel = opts.rho_fuel;
    L = opts.L_fuel;
    r_dot = opts.a*(G_ox.^opts.n);
    
    Sin_amp = opts.CombustionChamberSinusShapeAmplitude;
    C8 = opts.CombustionChamberInitialPerimeter;
    Rinit=opts.r_fuel_init;
    coeff = 1+(C8/(2*pi*Rinit) - 1)*exp(sqrt(6/Sin_amp)*(Rinit-r_fuel)*2/Rinit);
    
    m_dot_fuel = rho_fuel*2*pi*r_fuel*r_dot*L*coeff;
end

