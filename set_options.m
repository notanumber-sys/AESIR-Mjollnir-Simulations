function set_options(quick, plot_data, save_plots, static, full_duration, model, Cd, a, n, dr_thdt, n_inj, P_cc_init, T_tank_init, T_ext)
    % Sets all options and gets constants.
    global opts
    
    %% Manual settings.
    opts.quick = quick;                         % True if quick simulation should be done, might be less accurate. Useful for tuning.
    opts.plot_data = plot_data;                 % True if the data should be plot together with the simulations.
    opts.save_plots = save_plots;               % True if the resulting plots should be saved.
    opts.static = static;                       % True if simulation should be for a static fire, otherwise it is done for flight.
    opts.full_duration = full_duration;         % True if the tank parameters should be set to a full-duration burn, otherwise short-duration parameters are used.
    opts.model = model;                         % Mass flow model, one of {'Moody', 'Dyer'}.
    opts.Cd = Cd;                               % Discharge coefficient.
    opts.a = a;                                 % Fuel regression parameter a in r_dot = a*G_o^n (see Sutton, 2017, p. 602).
    opts.n = n;                                 % Fuel regression parameter n in r_dot = a*G_o^n (see Sutton, 2017, p. 602).
    opts.dr_thdt = dr_thdt;                     % Constant approximation of regression rate (m/s).
    opts.n_inj = n_inj;                         % Number of injector holes.
    opts.P_cc_init = P_cc_init;                 % Initial pressure in the combustion chamber (Pa).
    opts.T_tank_init = T_tank_init;             % Initial tank temperature (K).
    opts.T_wall_init = T_tank_init;             % Assume that initial tank wall temperature is equal to the initial internal temperature (K).
    opts.T_ext = T_ext;                         % External (environment) temperature (K).
    
    [T_ext_COESA, ~, P_atm, ~] = atmoscoesa(0);
    opts.dT_ext = T_ext_COESA - opts.T_ext;     % Difference between the COESA temperature and the actual temperature (K).
    opts.P_atm = P_atm;                         % Atmospheric pressure (Pa).
    
    %% Other settings (TODO: give good name).
    opts.filling_ratio = 0.95;      % Tank filling ratio.
    opts.launch_angle = 87;         % Launch angle (°).
    
    opts.drag_coefficient = 0.5;     
    opts.combustion_efficiency = 0.9;
    
    %% Physical constants.
    opts.g = 9.81;                                  % Gravitational constant (m/s^2).
    opts.R = 8.314;                                 % Universal gas constant (J/K/mol).
    
    opts.stephan_cst = 5.67e-8;                     % Stephan-Boltzman constant (W/m2/K4).
    opts.eber_parameter = 0.89;                     % Eber parameter for vertex angle between 20-50 degrees.
    opts.Molecular_weight_air = 28.9647e-3;         % Molecular weight of air (kg/mol).
    opts.r_air = opts.R / opts.Molecular_weight_air;
    
    %% Requirements.
    opts.design_altitude = 14000;          % Designed altitude to reach (m).
    opts.required_altitude = 12000;        % Mission requirements (m).
    
    %% Mass.
    opts.parachute_mass = 10;
    opts.electronics_mass = 2.3;
    opts.bodyTube_mass = 7;
    opts.payload_mass = 2;
    
    opts.propulsionSystem = 24.504;
    
    opts.dry_mass = opts.parachute_mass + opts.electronics_mass + opts.bodyTube_mass + opts.payload_mass + opts.propulsionSystem;
    
    opts.m_ox_init = 24.5;          % Oxidizer mass (kg).
    opts.m_fuel_init = 3.1;         % Fuel mass (kg).
    opts.rho_ox = 785;              % Oxidizer density (kg/m^3).
    
    %% Tank geometry.    
    if full_duration
        opts.D_ext_tank = 16e-2;    % Tank external diameter for full-duration burn (m).
        opts.L_tank = 1.83;         % Tank length for full-duration burn (m).
    else
        opts.D_ext_tank = 10e-2;    % Tank external diameter for short-duration burn (m).
        opts.L_tank = 0.73;         % Tank length for short-duration burn (m).
    end

    opts.e_tank = 3.5e-3;                                                   % Tank thickness.
    opts.D_int_tank = opts.D_ext_tank - 2 * opts.e_tank;    %9.42e-2;       % Tank internal diameter (m).
    opts.V_tank = pi * (opts.D_int_tank)^2 / 4 * opts.L_tank;   %33.1e-3;   % Tank volume (m^3) (present in Tank_Temperature_finder_fct).
    opts.surface = pi * (opts.D_ext_tank)^2 / 4;                            % Rocket surface.
    
    %% Kastrullen.
    opts.L_kastrullen = 35e-2;  % Length of Kastrullen.
    
    %% Injector geometry.             
    opts.r_inj = 1.2e-3 / 2;        % Injector radius (m).
    opts.L_inj = 15e-3;             % Injector plate thickness (m).
    
    opts.r_inj_plate = 30e-3;       % m
    opts.mass_inj = 0.271;          % kg
    opts.e_inj = 0.013;             % m
    
    %% Combustion chamber geometry.
    opts.D_cc_ext = 15.2e-2;                        % Combustion chamber external diameter (m).
    opts.e_cc = 4e-3;
    opts.D_cc_int = opts.D_cc_ext-2 * opts.e_cc;    % Combustion chamber interanl diameter (m)*.
    opts.L_cc_casing = 609.69e-3;                   % Combustion chamber total casing (pre_cc + cc).
    opts.L_pcc = 75e-3;                             % Pre-combustion chamber length.
    opts.mass_pcc = 0.5;                            % Pre-combustion chamber mass.
    opts.L_cc = 505.8e-3;                           % Combustion chamber total length(m).
    opts.T_cc = 3650;                               % Combustion chamber temperature (K).
    
    %% Ox properties.
    opts.Molecular_weight_ox = 44.013e-3;           % Molecular weight N2O (kg/mol).
    % opts.r_ox = opts.R/opts.Molecular_weight_ox;
    opts.gamma_ox = 1.31;                           % Adiabatic index coefficient N2O.
    opts.visc_nox = 2.98e-5;                        % Pa.s
    opts.calorific_capacity_nox = 2269.5;           % J/kg
    opts.thermal_conductivity_nox = 103e-3;         % W/m.K
     
    %% Fuel properties.
    opts.L_fuel = 33e-2;            % Fuel length (m).
    opts.fuel_mass_init = 3.1;      % Initial fuel mass (kg).
    opts.rho_fuel = 900;            % Density of fuel (kg/m^3).
    opts.r_fuel_init = 5e-2 / 2;    % Fuel port diameter at ignition.
    % opts.r_fuel_init = sqrt(opts.D_cc_int^2/4-opts.fuel_mass_init/(opts.rho_fuel*opts.L_fuel*pi));
    
    opts.fuel_margin_mass = 1.2;    % Mass of fuel that is for margin (kg).
    opts.fuel_margin_radius = sqrt(opts.D_cc_int^2 / 4 - opts.fuel_margin_mass / (opts.rho_fuel * opts.L_fuel * pi));
    
    opts.CombustionChamberSinusShapeAmplitude = 1/8 ;                                                           % Proportion of initial port radius.
    Sin_amp = opts.CombustionChamberSinusShapeAmplitude; 
    R = opts.r_fuel_init;
    dc = @(theta) sqrt((0.94 * R + R * Sin_amp * sin(8 * theta)).^2 + (R * Sin_amp * 8 * cos(8 * theta)).^2);   % Combustion diameter taking into account sinus shape.
    opts.CombustionChamberInitialPerimeter = integral(dc,0,2*pi);                                               % Perimeter taking into account sinus shape.
    
    %% Air properties sea level at 0°.   
    opts.rho_air_SL = 1.292;                    % Air density (kg/m^3).
    opts.visc_dyn_air_SL = 1.729e-5;            % Air dynamic viscosity (kg/m.s).
    opts.cp_air_SL = 1006;                      % Specific heat of air (J/kg.K).
    opts.air_thermal_conductivity = 0.02364;    % Thermal conductivity air (W/m.K).
    
    %% Combustion properties.
    opts.gamma_combustion_products = 1.18;                  % Heat capacity ratio.
    opts.molecular_weight_combustion_products = 29e-3;      % Molecular weight of products (kg/mol).
    opts.T_cc = 3700;                                       % Combustion temperature (K).
    
    %% Nozzle properties.
    opts.D_throat = 38.4e-3;
    % opts.A_throat_init = pi*(opts.D_throat)^2/4;  % Nozzle throat area (m^2).
    Ae_At = 4.75;
    opts.D_exit = sqrt(Ae_At) * opts.D_throat;
    opts.A_exit = pi * (opts.D_exit)^2 / 4;         % Nozzle exit area (m^2).
    
    opts.beta_nozzle = 80;                          % Nozzle inlet angle (in °).
    opts.alpha_nozzle = 10;                         % Nozzle exit angle (in °).
    opts.L_nozzle = 154.55e-3;                      % Nozzle length (m).
    
    %% Tank properties.
    opts.aluminium_thermal_conductivity = 236;      % Wm-1K-1 at 0 degree celcius.
    opts.rho_alu = 2700;                            % Density aluminium (kg/m^3).
    opts.alu_thermal_capacity = 897;                % J/K/kg
    opts.aluminium_emissivity_painted = 0.8;        % Emissivity of painted tank.
    opts.aluminium_emissivity = 0.3;                % Emissivity of plain aluminium.
    opts.aluminium_absorbitivity = 0.4;             % Absorptivity of plain aluminium.
    
    %% Set up the import options.
    import_options_N2O = delimitedTextImportOptions("NumVariables", 8);
    
    % Specify range and delimiter.
    import_options_N2O.DataLines = [8, 602];
    import_options_N2O.Delimiter = ";";
    
    % Specify column names and types.
    import_options_N2O.VariableNames = ["TemperatureK", "Pressurebar", "Liquiddensitykgm", "Gasdensitykgm", "LiquidIntEnergy", "VaporIntEnergy", "LiquidEnthalpy", "VaporEnthalpy"];
    import_options_N2O.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double"];
    import_options_N2O.ExtraColumnsRule = "ignore";
    import_options_N2O.EmptyLineRule = "read";
    
    % Import the data.
    N2O = readtable("Datasets/nitrous-oxide_LVsaturation.csv", import_options_N2O);
    c_star = readtable("Datasets/characteristic_velocity.csv");
    
    %% Clear temporary variables.
    clear import_options_N2O
    
    %% Spline fitting.
    Temperature_set = N2O.TemperatureK;         % Get temperature range.
    N2O_Psat_set = N2O.Pressurebar;             % Get saturation pressure for the temperatures above.
    N2O_Rhol_set = N2O.Liquiddensitykgm;        % Get liquid density for the temperatures above.
    N2O_Rhog_set = N2O.Gasdensitykgm;           % Get gas density for the temperatures above.
    N2O_Ul_set = N2O.LiquidIntEnergy;           % Get liquid internal energy for the temperatures above.
    N2O_Ug_set = N2O.VaporIntEnergy;            % Get gas internal energy for the temperatures above.
    
    % Put all variables in a map under the shorthand names.
    names = {'T', 'Psat', 'Rhol', 'Rhog', 'Ul', 'Ug'};
    vars = [Temperature_set, N2O_Psat_set, N2O_Rhol_set, N2O_Rhog_set, N2O_Ul_set, N2O_Ug_set];
    N2O_vars = containers.Map;
    for i = 1:length(names)
        N2O_vars(string(names(i))) = vars(:, i);
    end
    
    % Specify the x and y variables that are required, and a name for each pair.
    xs = {'T', 'T', 'T', 'T', 'T', 'Psat', 'Psat', 'Psat'};
    ys = {'Psat', 'Rhol', 'Rhog', 'Ul', 'Ug', 'Rhog', 'Ul', 'Ug'};
    names = {'Psat', 'RhoL_T', 'RhoG_T', 'UL_T', 'UG_T', 'RhoG_P', 'UL_P', 'UG_P'};
    
    % Fit a spline to each (x, y) pair.
    for i = 1:length(names)
        x = N2O_vars(string(xs(i)));
        y = N2O_vars(string(ys(i)));
        name = string(names(i)) + '_N2O_spline';
        spln = csaps(x, y);                         % Fit a cubic smoothing spline to the data.
        opts.(name) = fnxtr(spln, 2);               % Extrapolate with a quadratic polynomial to avoid wonkiness at the boundaries.
    end
    
    % Plots for debugging.
    debug_plot = false;
    if debug_plot
        rows = ceil(sqrt(length(names)));
        tiledlayout(rows, rows)
        for i = 1:length(names)
            x = N2O_vars(string(xs(i)));
            y = N2O_vars(string(ys(i)));
            name = string(names(i)) + '_N2O_spline';
            nexttile
            hold on
            xlim([0.99 * min(x) 1.01 * max(x)])
            scatter(x, y, '.')
            fnplt(opts.(name))
            hold off
        end
    end
    
    % Delete temporary variables.
    clear debug_plot i name names N2O_vars spln vars x xs y ys;
    
    opts.OF_set = c_star.OF;                                % OF ratio range.
    opts.c_star_set = c_star.c_star;                        % Characteristic velocity c_star.
    % opts.C_Star_polynom=polyfit(OF_set,C_star_set,5);     % Interpolation degree 3.
    
    %% Storage tank geometry.

    % TODO: Make sure that this data is only used for the tank filling
    %       simulation and remove/move it.
    
    opts.D_ext_storage = 230e-3;                                        % Storage tank external diameter (m).
    opts.V_storage = 50e-3;                                             % Storage tank volume (m^3).
    opts.D_int_storage = opts.D_ext_storage - 2 * opts.e_tank;
    opts.L_storage = opts.V_storage / (pi * (opts.D_int_storage)^2 / 4);
    
    %% Filling properties.
    
    % TODO: Make sure that this data is only used for the tank filling
    %       simulation and remove/move it.
    
    opts.d_filling_inlet = 4.7e-3;      %2.5e-3;    % m 
    opts.d_filling_outlet = 0.9e-3;                 % m
    
    opts.S_inlet = pi * (opts.d_filling_inlet)^2 / 4;
    opts.S_outlet = pi * (opts.d_filling_outlet)^2 / 4;
    
    opts.P_storage_tank_init = fnval(opts.Psat_N2O_spline, opts.T_ext) * 10^6;
    opts.cd_inlet = 0.85;
    opts.cd_outlet = 0.95;
    % opts.r_ox = py.CoolProp.CoolProp.PropsSI('P','T',opts.T_ext,'Q', 1,'NitrousOxide') / py.CoolProp.CoolProp.PropsSI('D','T',opts.T_ext,'Q', 1,'NitrousOxide') / opts.T_ext;
    % opts.r_ox = 180.7175;
end
