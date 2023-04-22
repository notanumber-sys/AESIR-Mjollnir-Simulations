% Code to optimize value over Supercharge Pressure & tank temperature subcooling
tic
run('./../setup')


global opts


N_opti_rel = 4;
N_opti_abs = 4;

rel_tol_range = [1e-3, 1e-4, 1e-5, 1e-6];
abs_tol_range = [1e-3, 1e-4, 1e-5, 1e-6];
iteration = 1;

Heights = zeros(N_opti_rel,N_opti_abs);

for i=1:N_opti_rel
    for j=1:N_opti_abs
        
        dt = 0.1;
        t0=0;                   %initial time of ignition
        t_burn = 125;             %final time
        tf=t_burn+t0;           %time when propelant is compeltely burned
        t_range=[t0 tf];       %integration interval
        disp(" ")
        disp("Iteration : "+iteration+"/"+N_opti_rel*N_opti_abs)
        disp(" ")
        iteration = iteration+1;
        
        T_init_ext = 283.15;    %K
        T_init_tank = 287.15;          %K
        
        rho_liq = py.CoolProp.CoolProp.PropsSI('D','T',T_init_tank,'Q', 0,'NitrousOxide');
        rho_vap = py.CoolProp.CoolProp.PropsSI('D','T',T_init_tank,'Q', 1,'NitrousOxide');
        u_liq = py.CoolProp.CoolProp.PropsSI('U','T',T_init_tank,'Q', 0,'NitrousOxide');
        u_vap = py.CoolProp.CoolProp.PropsSI('U','T',T_init_tank,'Q', 1,'NitrousOxide');

        Fr_liq = opts.filling_ratio;        %WARNING : this is a volumic ratio and MUST NOT be confused with x, vapor massic ratio
        V_tank = opts.V_tank;

        m_liq = Fr_liq*V_tank*rho_liq;
        m_vap = (1-Fr_liq)*V_tank*rho_vap;

        m_ox_init=m_liq+m_vap;                                       %initial mass of oxidyzer in the tank
        U_total_init=m_liq*u_liq+m_vap*u_vap;                           %initial energy in the tank (both gaz and liquid phase)
        T_wall_init=T_init_ext;                                             %initial temperature of the tank wall (K)
        r_comb_chamber_init=opts.r_fuel_init;                            %initial radius in the combustion chamber (m)
        P_cc_init = 30*opts.P_atm_sl;                                   %initial pressure in combustion chamber (Pa)
        x_init=0;
        y_init=0;
        dxdt_init=0;
        dydt_init=0;
        r_throat_init = opts.D_throat/2;

        initial_conditions=[m_ox_init; U_total_init; T_wall_init; r_comb_chamber_init; r_throat_init; P_cc_init; x_init; y_init; dxdt_init; dydt_init];%initial vector
 
        [t,state] = ode23(@system_equations,t_range,initial_conditions);%state1=m_tank_total, state2=U_tank_total,state3=T_tank_wall
        y = state(:,8);

        
        Heights(i,j) = max(y);
        
        Psat_init = fnval(opts.Psat_N2O_spline,T_init_tank);
        
        clearvars -except i j tol Heights Diff_pressure opts t_range T_tank_range Ninj_range iteration N_opti_rel N_opti_abs
    
    end
end


figure(1)
contourf(Ninj_range,rel_tol_range,Heights/1000,[7,8,9,10,10.5,11,11.5,12,12.5,13,13.5,14])
ylabel("Tank Temperature (K)")
xlabel("Number of injectors")
view(2)
cb1 = colorbar;
cb1.Location = "southoutside";
cb1.Label.String = 'Max Altitude (km)';


figure(2)
contourf(Ninj_range,rel_tol_range,max(0,Diff_pressure(:,:,2)*10))
ylabel("Tank Temperature (K)")
xlabel("Number of injectors")
view(2)
cb2 = colorbar;
cb2.Location = "southoutside";
cb2.Label.String = '0.8*Psat - P_cc (bar)';

figure(3)
contourf(Ninj_range,rel_tol_range,Heights.*max(0,Diff_pressure(:,:,2)*10)./max(Diff_pressure(:,:,2)*10))
ylabel("Tank Temperature (K)")
xlabel("Number of injectors")
colorbar

figure(4)
contourf(Ninj_range,rel_tol_range,Heights.*min(1,max(0,Diff_pressure(:,:,2)*10)*10^6))
ylabel("Tank Temperature (K)")
xlabel("Number of injectors")
colorbar


