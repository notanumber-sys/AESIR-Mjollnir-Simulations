% Code to optimize value over Supercharge Pressure & tank temperature subcooling
tic
run('./../setup')


global opts


N_opti_temp = 10;
N_opti_pressure = 11;
% N_opti_Ninj = 6;

T_tank_range = linspace(278,287,N_opti_temp);
P_super_range = linspace(50e5,60e5,N_opti_pressure);
% Ninj_range = linspace(30,35,N_opti_Ninj);
iteration = 1;

Heights = zeros(N_opti_temp,N_opti_pressure);
Diff_pressure = zeros(N_opti_temp,N_opti_pressure,2);
Final_fuel_radius = zeros(N_opti_temp,N_opti_pressure);
Time_burn = zeros(N_opti_temp,N_opti_pressure);

% Heights = zeros(N_opti_temp,N_opti_Ninj);
% Diff_pressure = zeros(N_opti_temp,N_opti_Ninj,2);

for i=1:N_opti_temp
    for j=1:N_opti_pressure
        
        dt = 0.1;
        t0=0;                   %initial time of ignition
        t_burn = 70;             %final time
        tf=t_burn+t0;           %time when propelant is compeltely burned
        t_range=[t0 tf];       %integration interval
        disp(" ")
        disp("Iteration : "+iteration+"/"+N_opti_temp*N_opti_pressure)
        disp(" ")
        iteration = iteration+1;
        
        [T_ext_model, ~, ~, ~] = atmoscoesa(0);
        T_init_ext = T_tank_range(i);    %K
        opts.dT_ext = T_ext_model-T_init_ext;
        T_init_tank = T_init_ext;    %K
%         opts.n_inj = Ninj_range(j); 
        
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
        
        opts.tank_state = 100;
        [t,state] = RungeKunta4(@system_equations,t_range,0.005,initial_conditions);
        y = state(8,:);
        P_cc = state(6,:);
        
        Heights(i,j) = max(y);
        r_cc = state(4,:);  
        m_ox_total = state(1,:);
        
        
        Psat_init = fnval(opts.Psat_N2O_spline,T_init_tank);
        Diff_pressure(i,j,1) = Psat_init - max(P_cc)/10^6;
        Diff_pressure(i,j,2) = 0.8*Psat_init - max(P_cc)/10^6;
        Final_fuel_radius(i,j) = r_cc(end);
        Time_burn(i,j) = t(find((m_ox_total(1:end-1)-m_ox_total(2:end))==0,1));
        
        clearvars -except i j tol Time_burn Heights Diff_pressure Final_fuel_radius opts t_range T_tank_range Ninj_range iteration N_opti_temp N_opti_pressure P_super_range
    
    end
end
toc

%%

figure(1)
sgtitle("Optimization Tank Pressure and Temperature (Injector N=34, ⌀1.4mm, Cd = 0.83)")

subplot(2,2,1)
contourf(P_super_range/10^5,T_tank_range,Heights/1000,8:0.5:15,'ShowText','on')
title("Altitude Reached (km)")
ylabel("Tank Temperature (K)")
xlabel("Supercharge Pressure (bar)")
view(2)


subplot(2,2,2)
contourf(P_super_range/10^5,T_tank_range,Diff_pressure(:,:,2)*10,[-22 -16 -12 -8 -4 -2 -1 0 1 2 3],'ShowText','on')
title("Pressure Stability Margin : 0.8P_s_a_t - P_c_c (bar)")
ylabel("Tank Temperature (K)")
xlabel("Supercharge Pressure (bar)")
view(2)

margin_fuel = 62.4;%mm
limit_fuel = 72;%mm

subplot(2,2,3)
contourf(P_super_range/10^5,T_tank_range,(limit_fuel-Final_fuel_radius*1000)./(limit_fuel-margin_fuel)*100,40:5:135,'ShowText','on')
title("Fuel Margin Left (%)")
ylabel("Tank Temperature (K)")
xlabel("Supercharge Pressure (bar)")
view(2)

subplot(2,2,4)
contourf(P_super_range/10^5,T_tank_range,Time_burn,10:0.5:21,'ShowText','on')
title("Burn Time (s)")
ylabel("Tank Temperature (K)")
xlabel("Supercharge Pressure (bar)")
view(2)


