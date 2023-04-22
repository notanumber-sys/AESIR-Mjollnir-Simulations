%% Flight plots.

global opts

rows = 2;
columns = 4;
fig = figure(3);
fig.WindowState = 'maximized';
pause(0.1)  % Needed to make sure maximization takes effect before saving.
sgtitle("Flight", 'FontSize', 20, 'Color', 'Red', 'FontWeight', 'bold')

m_fuel = opts.rho_fuel * opts.L_fuel * pi * (opts.D_cc_int.^2 / 4 - simulation.r_cc.^2);


v = sqrt(simulation.vx.^2 + simulation.vy.^2);
acc = sqrt(simulation.ax.^2 + simulation.ay.^2);

Cd = drag_coefficient_model(v, simulation.speed_of_sound);
D = Cd .* 0.5 .* simulation.rho_ext .* v.^2 .* opts.surface;

Dx = D .* simulation.vx ./ v;
Dy = D .* simulation.vy ./ v;

%% Speed.
subplot(rows, columns, 1)
plot(simulation.t, v)
hold on
plot(simulation.t, simulation.vx)
plot(simulation.t, simulation.vy)
hold off

title("Speed")
xlabel("Time (s)")
ylabel("Speed (m/s)")
legend("Speed", "V_x", "V_y")
axis padded

%% Drag.
subplot(rows, columns, 2)
plot(simulation.t, D)
hold on
plot(simulation.t, Dx)
plot(simulation.t, Dy)
hold off

title("Drag")
xlabel("Time (s)")
ylabel("Drag (N)")
legend("Total", "D_x", "D_y")
axis padded

%% Acceleration.
subplot(rows, columns, 3);
plot(simulation.t, acc / 9.8)
hold on
plot(simulation.t, simulation.ax / 9.8)
plot(simulation.t, simulation.ay / 9.8)
hold off

title("Acceleration")
xlabel("Time (s)")
ylabel("Acceleration (g)")
legend("Total", "a_x", "a_y")
axis padded

%% Mach number.
subplot(rows, columns, 4);
plot(simulation.t, v ./ simulation.speed_of_sound)

title("Mach number")
xlabel("Time (s)")
ylabel("Mach")
axis padded

%% Trajectory.
subplot(rows, columns, 5)
plot(simulation.x / 1000, simulation.y / 1000)
hold on
yline(opts.design_altitude / 1000, '--', 'Color', '#77AC30')
yline(opts.required_altitude / 1000, '--', 'Color', '#D95319')
hold off

title("Trajectory")
xlabel("Longitudinal distance (km)")
ylabel("Height (km)")
legend("Trajectory", "Design", "Required", 'Location', 'southeast')
axis padded

%% Height.
subplot(rows, columns, 6)
plot(simulation.t, simulation.y / 1000)
hold on
yline(opts.design_altitude / 1000, '--', 'Color', '#77AC30')
yline(opts.required_altitude / 1000, '--', 'Color', '#D95319')
hold off

title("Height")
xlabel("Time (s)")
ylabel("Height (km)")
ylim([0, opts.design_altitude / 1000])
legend("Trajectory", "Design", "Required", 'Location', 'southeast')
axis padded

%% Angle.
subplot(rows, columns, 7);
plot(simulation.t, 90 - atand(simulation.x ./ simulation.y))

title("Angle")
xlabel("Time (s)")
ylabel("Angle relative to local horizontal (°)")
axis padded

%% Dynamic pressure.
subplot(rows, columns, 8);
plot(simulation.y / 1000, 0.5 * simulation.rho_ext .* v.^2. / 10^5)

title("Dynamic pressure over altitude")
xlabel("Altitude (km)")
ylabel("Dynamic pressure (bar)")
axis padded

%% Save plots.
if opts.save_plots
    % Rename old plot for easy comparison.
    if exist('./Plots/flight_plot.fig', 'file') == 2
        movefile('./Plots/flight_plot.fig', './Plots/flight_plot_old.fig')
    end

    saveas(fig, './Plots/flight_plot.fig')
    exportgraphics(fig, './Plots/flight_plot.png', 'Resolution', 300)
end
