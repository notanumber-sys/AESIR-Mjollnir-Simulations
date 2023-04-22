%% Combustion plots.

global opts

rows = 2;
columns = 4;
fig = figure(1);
fig.WindowState = 'maximized';
sgtitle("Combustion", 'FontSize', 20, 'Color', 'blue', 'FontWeight', 'bold')

if opts.full_duration
    t_burn = 25;
else
    t_burn = 8;
end
sim_ind = find(simulation.t < t_burn);
t_sim = simulation.t(sim_ind);
t_data = linspace(0, t_burn, 1000);

%% Port radius.
subplot(rows, columns, 1);
plot(t_sim, simulation.r_cc(sim_ind) * 1000)
hold on
yline(opts.D_cc_int / 2 * 1000, '--', 'Color', '#A2142F')
yline(opts.fuel_margin_radius * 1000, '--', 'Color', '#D95319')
hold off

title("Port radius")
xlabel("Time (s)")
ylabel("Port radius (mm)")
legend("Port radius", "External tank limit", "Fuel margin limit", 'Location', 'southeast')
axis padded

%% Tank temperature.
subplot(rows, columns, 2)
v = sqrt(simulation.vx.^2 + simulation.vy.^2);
T_wall_ext = simulation.T_ext + v.^2 ./ (2 .* simulation.cp_air);
plot(t_sim, simulation.T_tank(sim_ind))
hold on
plot(t_sim, simulation.T_tank_wall(sim_ind)) 
plot(t_sim, simulation.T_ext(sim_ind))
hold off

title("Tank temperature")
xlabel("Time (s)")
ylabel("Temperature (K)")
legend("Internal", "External", "Air", 'Location', 'east')
axis padded

%% Frictional temperature.
subplot(rows, columns, 3)
plot(t_sim, T_wall_ext(sim_ind))

title("Frictional temperature")
xlabel("Time (s)")
ylabel("Temperature (K)")
axis padded

%% Fuel regression rate.
subplot(rows, columns, 4)
A_port = pi * simulation.r_cc'.^2;
G_Ox = simulation.mf_ox ./ A_port;
drdt = opts.a * G_Ox.^opts.n;
plot(t_sim, drdt(sim_ind) * 1000)

title("Fuel regression rate")
xlabel("Time (s)")
ylabel("Regression rate (mm/s)")
axis padded

%% Mass flow.
subplot(rows, columns, 5)
plot(t_sim, simulation.mf_ox(sim_ind))
hold on
plot(t_sim, simulation.mf_fuel(sim_ind))
plot(t_sim, simulation.mf_throat(sim_ind))
if opts.plot_data
    % TODO: Might be nice to incorporate computations into data processing.
    time = data.TANK_WEIGHT_DATA(:, 1);
    weight = data.TANK_WEIGHT_DATA(:, 2);
    spln = csaps(time, weight);             % Fit a cubic smoothing spline.
    spln = fnxtr(spln, 2);                  % Extrapolate with a quadratic polynomial to avoid wonkiness at the boundaries.
    mass_flow = fnder(spln);                % Take derivative of mass over time to get mass flow.
    plot(t_data, -fnval(mass_flow, t_data), '--', 'Color', '#0072BD');         
end
hold off

title("Mass flow")
xlabel("Time (s)")
ylabel("Mass flow (kg/s)")
if opts.plot_data
    legend("Oxidizer", "Fuel", "Throat", "Oxidizer (actual)", 'Location', 'east')
else
    legend("Oxidizer", "Fuel", "Throat", 'Location', 'east')
end
axis padded

%% O/F ratio.
subplot(rows, columns, 6)
plot(t_sim, simulation.OF(sim_ind))

title("O/F ratio")
xlabel("Time (s)")
ylabel("O/F")
axis padded

%% Pressure.
subplot(rows, columns, 7)
plot(t_sim, simulation.P_tank(sim_ind) / 10^6)
hold on
plot(t_sim, simulation.P_cc(sim_ind) / 10^6)
plot(t_sim, simulation.P_ex(sim_ind) / 10^6)
if opts.plot_data
    % Plot actual top and bottom pressure (divide by 10 for bar to MPa conversion and add atmospheric pressure).
    plot(t_data, data.PTRAN_1_I(t_data) / 10 + opts.P_atm / 1e6, '--', 'Color', '#0072BD');
    plot(t_data, data.PTRAN_2_I(t_data) / 10 + opts.P_atm / 1e6, ':', 'Color', '#0072BD');
    plot(t_data, data.PTRAN_4_I(t_data) / 10 + opts.P_atm / 1e6, '--', 'Color', '#D95319');
end
hold off

title("Pressure")
xlabel("Time (s)")
ylabel("Pressure (MPa)")
if opts.plot_data
    legend("Tank", "CC", "Exhaust", "Top (actual)", "Bottom (actual)", "CC (actual)", 'Location', 'northeast')  % Note: Tank pressure at saturation.
else
    legend("Tank", "CC", "Exhaust", 'Location', 'northeast')  % Note: Tank pressure at saturation.
end
axis padded

%% Tank fill.
subplot(rows, columns, 8)
plot(t_sim, simulation.V_liq(sim_ind) * 1000)
hold on
yline(opts.V_tank * 1000, '--', 'Color', '#D95319')
hold off

title("N2O volume in tank")
xlabel("Time (s)")
ylabel("Volume (L)")
legend("Volume", "Full", 'Location', 'east')
axis padded

%% Save plots.
if opts.save_plots
    % Rename old plot for easy comparison.
    if exist('./Plots/combustion_plot.fig', 'file') == 2
        movefile('./Plots/combustion_plot.fig', './Plots/combustion_plot_old.fig')
    end
    
    saveas(fig, './Plots/combustion_plot.fig')
    exportgraphics(fig, './Plots/combustion_plot.png', 'Resolution', 300)
end
