%% Flight plots.

global opts

rows = 2;
columns = 4;
figure(1)
sgtitle("Flight Parameters", 'FontSize', 20, 'Color', 'Red', 'FontWeight', 'bold')

m_fuel = opts.rho_fuel * opts.L_fuel * pi * (opts.D_cc_int.^2 / 4 - simulation.r_cc.^2);


v = sqrt(simulation.vx.^2 + simulation.vy.^2);
acc = sqrt(simulation.ax.^2 + simulation.ay.^2);

Cd = drag_coefficient_model(v, simulation.speed_of_sound);
D = Cd .* 0.5 .* simulation.rho_ext .* v.^2 .* opts.surface;

Dx = D .* simulation.vx ./ v;
Dy = D .* simulation.vy ./ v;

%% Speed.
subplot(rows, columns, 1)
hold on
plot(simulation.t, v)
plot(simulation.t, simulation.vx)
plot(simulation.t, simulation.vy)
title("Speed")
xlabel("Time (s)")
ylabel("Speed (m/s)")
legend("Speed", "V_x", "V_y")
hold off

%% Drag.
subplot(rows, columns, 2)
hold on
plot(simulation.t, D)
plot(simulation.t, Dx)
plot(simulation.t, Dy)
title("Drag")
xlabel("Time (s)")
ylabel("Drag (N)")
legend("Total", "D_x", "D_y")
hold off

%% Acceleration.
subplot(rows, columns, 3);
hold on
plot(simulation.t, acc / 9.8)
plot(simulation.t, simulation.ax / 9.8)
plot(simulation.t, simulation.ay / 9.8)
title("Acceleration")
xlabel("Time (s)")
ylabel("Acceleration (g)")
legend("Total", "a_x", "a_y")
hold off

%% Mach number.
subplot(rows, columns, 4);
plot(simulation.t, v ./ simulation.speed_of_sound)
title("Mach number")
xlabel("Time (s)")
ylabel("Mach")

%% Trajectory.
subplot(rows, columns, 5)
hold on
plot(simulation.x / 1000, simulation.y / 1000)
plot(simulation.x / 1000, opts.design_altitude / 1000, '--')
plot(simulation.x / 1000, opts.required_altitude / 1000)
title("Trajectory")
xlabel("Longitudinal distance (km)")
ylabel("Height (km)")
legend("Trajectory", "Design", "Required")
hold off

%% Height.
subplot(rows, columns, 6)
hold on
plot(simulation.t, simulation.y / 1000)
plot(simulation.t, opts.design_altitude / 1000, '--')
plot(simulation.t, opts.required_altitude / 1000)
title("Height")
xlabel("Time (s)")
ylabel("Height (km)")
legend("Trajectory", "Design", "Required")
hold off

%% Angle.
subplot(rows, columns, 7);
plot(simulation.t, 90 - atand(simulation.x ./ simulation.y))
title("Angle")
xlabel("Time (s)")
ylabel("Angle relative to local horizontal (°)")

%% Dynamic pressure.
subplot(rows, columns, 8);
plot(simulation.y / 1000, 0.5 * simulation.rho_ext .* v.^2. / 10^5)
title("Dynamic pressure over altitude")
xlabel("Altitude (km)")
ylabel("Dynamic pressure (bar)")
