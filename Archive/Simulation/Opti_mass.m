% Code to optimize value over Supercharge Pressure & tank temperature subcooling
tic

run('./../setup')

global opts
dt = 0.1;

t0=0;                     %initial time of ignition
t_burn = 125;             %final time
tf=t_burn+t0;           %time when propelant is compeltely burned
t_range=[t0 tf];       %integration interval

N_opti_mass = 10;
tol = odeset('RelTol',1e-4,'AbsTol',1e-6);

mass_range = linspace(40,50,N_opti_mass);
iteration = 1;

Heights = zeros(1,N_opti_mass);

for i=1:N_opti_mass
    
        disp(" ")
        disp("Iteration : "+iteration+"/"+N_opti_mass)
        disp(" ")
        iteration = iteration+1;
        pause(2)
        
        T_init_ext = 278.15;    %K
        T_init_tank = 287.13;          %K
       
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
        opts.dry_mass = mass_range(i);
        initial_conditions=[m_ox_init; U_total_init; T_wall_init; r_comb_chamber_init; r_throat_init; P_cc_init; x_init; y_init; dxdt_init; dydt_init];%initial vector
 
        [t,state] = ode15s(@system_equations,t_range,initial_conditions,tol);%state1=m_tank_total, state2=U_tank_total,state3=T_tank_wall
        y = state(:,8);
        Pcc = state(:,6);
        
        Heights(i) = max(y);
        
        
        clearvars -except i j tol Heights opts t_range mass_range iteration N_opti_mass
    
end
toc

figure(1)
plot(mass_range,Heights/1000)
ylabel("Max Altitude (km)")
xlabel("Dry Mass of whole rocket")



