tic
run('./../setup')

global opts

%Combustion parameters

opts.tank_state = 100;

dt = 0.1;

t0=0;                   %initial time of ignition
t_burn = 125;             %final time
tf=t_burn+t0;           %time when propelant is compeltely burned
t_range=[t0 tf];       %integration interval

%Initial conditions
disp("-----------------------")
disp("Intitialization") 
disp("-----------------------")
disp(" ")


%% Influencial Parameters

[T_ext_model, ~, ~, ~] = atmoscoesa(0);
T_init_ext = 287;    %K
opts.dT_ext = T_ext_model-T_init_ext;
T_init_tank = T_init_ext;    %K
% opts.dry_mass = 42;


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

tol = odeset('RelTol',10^-5,'AbsTol',10^-3);
initial_conditions=[m_ox_init; U_total_init; T_wall_init; r_comb_chamber_init; r_throat_init; P_cc_init; x_init; y_init; dxdt_init; dydt_init];%initial vector

%Solve initial value problem for ODE
disp("-----------------------")
disp("Solving Differential Eq") 
disp("-----------------------")
disp(" ")
[t,state] = ode45(@System_equations,t_range,initial_conditions);%state1=m_tank_total, state2=U_tank_total,state3=T_tank_wall

m_ox_total = state(:,1);                          %total mass in the tank according to time

empty_tank = find(m_ox_total < 0);
empty_tank_mask = ones(length(t),1);
empty_tank_mask(empty_tank)=0;

m_ox_total = m_ox_total.*empty_tank_mask;                                  %total mass in the tank according to time
U_tank_total = state(:,2).*empty_tank_mask;                                %total energy inside the tank according to time
T_tank_wall = state(:,3);                                                  %wall temperature of the tank according to time
r_cc = state(:,4);                                                         %Combustion chamber radius according to time
r_throat = state(:,5);
P_cc = state(:,6).*empty_tank_mask+opts.P_atm_sl.*(1-empty_tank_mask);     %Pressure chamber
x = state(:,7);
y = state(:,8);
vx = state(:,9);
vy = state(:,10);

%Post recuperation of Data
N = length(vx);
T_tank = zeros(1,N);
P_tank = zeros(1,N);
x_vap = zeros(1,N);
mf_ox = zeros(1,N);
mf_fuel = zeros(1,N);
OF = zeros(1,N);
mf_throat = zeros(1,N);
T_cc = zeros(1,N);
Tr = zeros(1,N);
ax = zeros(1,N);
ay = zeros(1,N);
Me = zeros(1,N);
Ve = zeros(1,N);
Pe = zeros(1,N);
At = pi*r_throat.^2;
cp_air = zeros(1,N);
P_N2O = zeros(1,N);
m_fuel = zeros(1,N);
h_liq = zeros(1,N);
h_gas = zeros(1,N);
h_air_ext = zeros(1,N);
m_tot = zeros(1,N);

[T_ext, speed_of_sound, P_ext, rho_ext] = atmoscoesa(y);

A_port = pi*r_cc.^2;

gam = opts.gamma_combustion_products;
Mw=opts.molecular_weight_combustion_products;
R=opts.R;

toc
disp(max(y))
pause(10)

%%
disp("-----------------------")
disp("Post-Compute Calcultion") 
disp("-----------------------")
disp(" ")


for i=1:length(T_tank)
    [dstatedt, m_tot(i), h_liq(i), h_gas(i), h_air_ext(i)] = System_equations(t(i), state(i,:)');
    ax(i) = dstatedt(8);
    ay(i) = dstatedt(9);
    
    if ~ismember(i,empty_tank)
        T_tank(i) = Tank_Temperature(U_tank_total(i),m_ox_total(i));
        x_vap(i) = x_vapor(U_tank_total(i),m_ox_total(i),T_tank(i));
        
        rho_vap = fnval(opts.RhoG_T_NO2_spline,T_tank(i));
        rho_liq = fnval(opts.RhoL_T_NO2_spline,T_tank(i));
        Tank_state = (1-x_vap(i))*m_ox_total(i)/(rho_liq*opts.V_tank)*100;
        T_N2 = T_tank(i);
        V_N2 = x_vap(i)*m_ox_total(i)/rho_vap;
        
        P_N2O(i) = fnval(opts.Psat_NO2_spline,T_tank(i))*10^6;
        P_tank(i) = P_N2O(i);
        
        mf_ox(i) = Mass_flow_oxidizer(T_tank(i),P_tank(i),P_cc(i));
        G_Ox = mf_ox(i)/A_port(i);
        mf_fuel(i) = Mass_flow_fuel(G_Ox,r_cc(i));
        OF(i)=mf_ox(i)/mf_fuel(i);
        mf_throat(i) = Mass_flow_throat(P_cc(i),OF(i),At(i)); 
        c_star = interp1q(opts.OF_set,opts.C_star_set,OF(i));
        T_cc(i) = gam*(2/(gam+1))^((gam+1)/(gam-1))*c_star^2*Mw/R;
        Me(i) = ExhaustMach(opts,At(i));
        Pe(i) = ExhaustPressure(P_cc(i),P_ext(i),Me(i),opts);
        Ve(i) = ExhaustSpeed(T_cc(i),Pe(i),P_cc(i),opts);
        Tr(i) = opts.combustion_efficiency*Thrust(mf_throat(i),Ve(i),P_ext(i),Pe(i),opts);
        cp_air(i) = py.CoolProp.CoolProp.PropsSI('C','P',P_ext(i),'T', (T_ext(i)+T_tank_wall(i))/2,'Air');
        m_fuel(i) = opts.rho_fuel*opts.L_fuel*pi*(opts.D_cc_int^2/4-r_cc(i)^2);
    else
        index = empty_tank(1)-1;
        T_tank(i) = T_tank(index);
        P_tank(i)=opts.P_atm_sl;
        T_cc(i)=T_cc(index);
    end
end



disp("-----------------------")
disp("Plotting") 
disp("-----------------------")
disp(" ")
plots;