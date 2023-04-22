run('../../setup')
run('../../Data')

global opts
global dt

dt = 0.01;

t0=0;                           %initial time of filling
t_filling =6*60;               %final time
tf=t_filling+t0;                %arbitrary time 
t_range=t0:0.01:tf;                %integration interval

%Initial conditions
disp("-----------------------")
disp("Intitialization") 
disp("-----------------------")
disp(" ")

T_init = opts.T_ext;    %K
V_tank = opts.V_tank;   %m^3
opts.P_storage_tank = 50e5; %50 bars, to be checked and to be defined in data file 

rho_vap = py.CoolProp.CoolProp.PropsSI('D','P',opts.P_storage_tank, 'Q', 1,'NitrousOxide');

% V_liq_init = 0;
V_vap_init = V_tank;
m_liq_init = 0;
m_vap_init = opts.P_storage_tank*V_tank/(opts.r_ox*T_init);%rho_vap*V_vap_init;%

u=py.CoolProp.CoolProp.PropsSI('U','T',T_init,'Q', 1,'NitrousOxide');
U_tot_init = m_vap_init*u;

initial_conditions=[m_liq_init; m_vap_init; U_tot_init];   %initial vector

%Solve initial value problem for ODE
disp("-----------------------")
disp("Solving Differential Eq") 
disp("-----------------------")
disp(" ")
[t,state] = ode45(@System_of_equations_filling,t_range,initial_conditions);


m_liq = state(:,1);
m_vap = state(:,2);
U_tot = state(:,3);

mdot_in = zeros(1,length(m_liq));
P_tank = zeros(1,length(m_liq));

%%

for i=1:length(m_liq)
     [state_vector, mdot_in_i, P_tank_i] = System_of_equations_filling(state(i,:),state(i,:));
     mdot_in(i) = mdot_in_i;
     P_tank(i) = P_tank_i;
     
end
    
    
    

Results_plots;
