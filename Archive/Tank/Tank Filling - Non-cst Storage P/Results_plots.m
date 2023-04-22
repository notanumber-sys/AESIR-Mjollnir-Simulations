global opts

lignes=2;
colonnes=3;
figure(1)
sgtitle("Filling Parameters",'FontSize', 20, 'Color','black','FontWeight','bold')


%% Mass tank


m_vap_tank = (x_tank').*m_N2O_tank;
rho_vap_tank = fnval(opts.RhoG_T_NO2_spline,T_tank);
V_vap_tank = m_vap_tank./rho_vap_tank';

m_liq_tank = (1-x_tank').*m_N2O_tank;
rho_liq_tank = fnval(opts.RhoL_T_NO2_spline,T_tank);
V_liq_tank = m_liq_tank./rho_liq_tank';


subplot(lignes,colonnes,1);
plot(t/60,V_liq_tank/opts.V_tank*100,t/60, V_vap_tank/opts.V_tank*100)
ylabel('Rocket Tank filling (in %)')
xlabel('Time in min')
title('Tank filling over time')
legend("V_l_i_q","V_v_a_p")

%% Mass storage

rho_vap_storage = fnval(opts.RhoG_T_NO2_spline,T_storage);
m_vap_storage = (x_storage).*m_storage';
V_vap_storage = m_vap_storage./rho_vap_storage;

rho_liq_storage = fnval(opts.RhoL_T_NO2_spline,T_storage);
m_liq_storage = (1-x_storage).*m_storage';
V_liq_storage = m_liq_storage./rho_liq_storage;

subplot(lignes,colonnes,2);
plot(t/60,V_liq_storage/opts.V_storage*100,t/60, V_vap_storage/opts.V_storage*100)
ylabel('Storage Tank filling (in %)')
xlabel('Time in min')
title('Storage emptining over time')
legend("V_l_i_q","V_v_a_p")

%% Mass flow

Wdot_star_inlet = opts.cd_inlet*opts.S_inlet.*P_storage./sqrt(T_storage)*sqrt(opts.gamma_ox/opts.r_ox)*sqrt((2/(opts.gamma_ox+1))^((opts.gamma_ox+1)/(opts.gamma_ox-1)));
Wdot_star_outlet = opts.cd_outlet*opts.S_outlet.*P_tank./sqrt(T_tank)*sqrt(opts.gamma_ox/opts.r_ox)*sqrt((2/(opts.gamma_ox+1))^((opts.gamma_ox+1)/(opts.gamma_ox-1)));


subplot(lignes,colonnes,3);
plot(t/60,mdot_in,t/60,Wdot_star_inlet, t/60, mdot_out, t/60, Wdot_star_outlet)
ylabel("Mass flow (kg/s)")
xlabel("Time (min)")
legend("Mass flow in (tank)","Critical Mass flow inlet", "Mass flow out (tank)", "Critical Mass flow outlet")
title("Mass flow over time")


%% Pressure

subplot(lignes,colonnes,4);
plot(t/60,P_tank/10^5, t/60, P_storage/10^5)
ylabel("Pressure (bar)")
xlabel("Time (min)")
title("Pressure")
legend("Rocket Tank","Storage Tank")

%% x

subplot(lignes,colonnes,5);
plot(t/60,x_tank,t/60,x_storage)
ylabel("Vapor quality")
xlabel("Time (min)")
title("x")
legend("x_t_a_n_k","x_s_t_o_r_a_g_e")


%% Temperature storage


subplot(lignes,colonnes,6);
plot(t/60,T_wall_tank, t/60, T_tank', t/60, T_wall_storage, t/60, T_storage');
ylabel("Wall Temperature (K)")
xlabel("Time (min)")
title("Wall Temperature over time")
legend("Tank Wall", "Tank", "Storage Wall", "Storage")


