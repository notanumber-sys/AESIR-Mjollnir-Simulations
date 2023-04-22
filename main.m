%% This file is the main user interface.
%{
    Some notes on hyperparameter tuning:
    - Set the external temperature based on conditions during testing/launch.
    - To tune the tank pressure:
        - A higher T_tank_init tends to move the initial tank pressure up.
        - A higher Cd tends to result in a steeper slope.
    - To tune the combustion chamber pressure:
        - A higher Cd tends to move the initial combustion chamber pressure up.
        - A higher dr_thdt tends to result in a steeper slope.
    - To tune the fuel regression rate.
        - Tweak a and n.
        - This data has not been available yet, so beware that these parameters are not tuned.
%}
setup;

%% User settings.
run_simulation = true;      % True if the simulation should be run, if false it will load the most recent simulation.
process_data = false;        % TODO: it would be nice to integrate this more properly into the main.
data_name = "Datasets/HT-2/ht21_large.mat";

plot_data = false;           % True if the data should be plot together with the simulations.
save_plots = true;          % True if the resulting plots should be saved.

%% Model parameters.
quick = false;               % True if quick simulation should be done. Less accurate, but useful for tuning.
static = true;              % True if simulation should be for a static fire, otherwise it is done for flight.
full_duration = false;       % True if the tank parameters should be set to a full-duration burn, otherwise short-duration parameters are used.
model = 'Moody';             % Mass flow model, one of {'Moody', 'Dyer'}. Uses Moody by default.
Cd = 0.85;                  % Discharge coefficient.
a = 20e-5;                  % Fuel regression parameter a in r_dot = a*G_o^n (see Sutton, 2017, p. 602).
n = 0.55;                   % Fuel regression parameter n in r_dot = a*G_o^n (see Sutton, 2017, p. 602). Typical range: [0.4, 0.7].
dr_thdt = 0.35e-2;           % Constant approximation of regression rate (m/s).

%% Vehicle parameters.
n_inj = 80;                 % Number of injector holes.

%% Environment parameters.
% TODO: Retrieve from data?
P_cc_init = 2500000;        % Initial pressure in the combustion chamber (Pa). Needs to be quite high for the model to work.
T_tank_init = 285;          % Initial tank temperature (K).
T_ext = 282;                % External (environment) temperature (K).

%% Set options.
set_options(quick, plot_data, save_plots, static, full_duration, model, Cd, a, n, dr_thdt, n_inj, P_cc_init, T_tank_init, T_ext)

%% Run or load simulations.
if run_simulation
    % Run simulations.
    simulate();
end
simulation = load("simulation_results.mat");

%% Data processing.
if process_data
    disp("")          %% TODO: data processing.
else
    data = load(data_name); 
    data = data.data;
end

%% Plot the simulation results.
plot_results;
