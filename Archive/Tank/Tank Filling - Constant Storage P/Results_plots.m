global opts

lignes=2;
colonnes=2;
figure(1)
sgtitle("Filling Parameters",'FontSize', 20, 'Color','black','FontWeight','bold')


T_ext=opts.T_ext;
T_tank=T_ext;
rho_liq=py.CoolProp.CoolProp.PropsSI('D','T',T_tank,'Q', 0,'NitrousOxide');


%% Volume

subplot(lignes,colonnes,1);
plot(t/60,100*m_liq/opts.V_tank/rho_liq,t/60,100-100*m_liq/opts.V_tank/rho_liq)
ylabel('Tank filling in %')
xlabel('Time in min')
title('Tank filling versus time')
legend('V_l_i_q','V_v_a_p')%(*) atm simple version of V_vap



%% Mass flow

Wdot_star = opts.cd_inlet*opts.S_inlet*opts.P_storage_tank/sqrt(opts.T_ext)*sqrt(opts.gamma_ox/opts.r_ox)*sqrt((2/(opts.gamma_ox+1))^((opts.gamma_ox+1)/(opts.gamma_ox-1)));

subplot(lignes,colonnes,2);
plot(t/60,mdot_in,t/60,mdot_in*0+Wdot_star)
ylabel("Mass flow (kg/s)")
xlabel("Time (min)")
legend("Mass flow","Critical Mass flow")
title("Mass flow")


%% Pressure

subplot(lignes,colonnes,3);
plot(t/60,P_tank/10^5)
ylabel("Pressure (bar)")
xlabel("Time (min)")
title("Pressure")
