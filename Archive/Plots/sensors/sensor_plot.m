%% Plots of sensors

global opts

lignes=5;
colonnes=2;
figure(4)
sgtitle("Sensor Readings - Simulation",'FontSize', 20, 'Color','black','FontWeight','bold')

sensor_compute;
t_burn = 15;
t_comb=t(find(t<t_burn));

%% Temperature tank

subplot(lignes,colonnes,1);
plot(t_comb,T_sensor_tank_top(find(t<t_burn)),t_comb,T_sensor_tank_mid(find(t<t_burn)),t_comb,T_sensor_tank_bot(find(t<t_burn)))
title("Oxidizer Tank")
% xlabel("Time (s)")
ylabel("Temperature (K)")
lgd = legend("Top","Mid","Bot");
lgd.Location = 'northeast';

%% Pressure tank

subplot(lignes,colonnes,2);
plot(t_comb,P_sensor_vent(find(t<t_burn))/10^6)
title("Oxidizer Tank")
% xlabel("Time (s)")
ylabel("Pressure (MPa)")

%% Temperature Kast

subplot(lignes,colonnes,3);
plot(t_comb,T_sensor_kast_top(find(t<t_burn)))
title("Pipework")
% xlabel("Time (s)")
ylabel("Temperature (K)")

%% Pressure Injector

subplot(lignes,colonnes,[4,6]);
plot(t_comb,P_sensor_inj(find(t<t_burn))/10^6)
title("Injector")
% xlabel("Time (s)")
ylabel("Pressure (MPa)")

%% Temperature Injector

subplot(lignes,colonnes,5);
plot(t_comb,T_sensor_inj_top(find(t<t_burn)),t_comb,T_sensor_inj_bot(find(t<t_burn)))
title("Injector")
% xlabel("Time (s)")
ylabel("Temperature (K)")
lgd = legend("Top","Bot");
lgd.Location = 'southeast'; 

%% Temperature CC

subplot(lignes,colonnes,7);
plot(t_comb,T_sensor_CC_top(find(t<t_burn)),t_comb,T_sensor_CC_fuel(find(t<t_burn)),t_comb,T_sensor_CC_bot(find(t<t_burn)))
title("Combustion Chamber")
% xlabel("Time (s)")
ylabel("Temperature (K)")
lgd = legend("Top","Fuel","Bot");
lgd.Location = 'southeast'; 

%% Pressure CC

subplot(lignes,colonnes,8);
plot(t_comb,P_sensor_CC(find(t<t_burn))/10^6)
title("Combustion Chamber")
% xlabel("Time (s)")
ylabel("Pressure (MPa)")

%% Temperature Nozzle

subplot(lignes,colonnes,9);
plot(t_comb,T_sensor_throat(find(t<t_burn)))
title("Throat")
xlabel("Time (s)")
ylabel("Temperature (K)")

%% Pressure Ambient

subplot(lignes,colonnes,10);
plot(t_comb,P_ext(find(t<t_burn))/10^6)
title("Ambient")
xlabel("Time (s)")
ylabel("Pressure (MPa)")


