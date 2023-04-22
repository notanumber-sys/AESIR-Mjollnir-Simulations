run('./../setup')

global opts
global dt

dt = 0.05;

t0=0;                               %initial time of filling
t_filling = 10*60;                   %final time
tf=t_filling+t0;                    %arbitrary time 
t_range=t0:dt:tf;                   %integration interval

%Initial conditions
disp("-----------------------")
disp("Intitialization") 
disp("-----------------------")
disp(" ")

T_init = opts.T_ext;    %K
V_tank = opts.V_tank;   %m^3

rho_vap = fnval(opts.RhoG_T_NO2_spline,opts.T_ext);
rho_liq = fnval(opts.RhoL_T_NO2_spline,opts.T_ext);

m_N2O_tank_init = rho_vap*opts.V_tank;
U_tank_init = m_N2O_tank_init*fnval(opts.UG_T_NO2_spline,opts.T_ext)*10^3;

m_N2O_storage_init = rho_liq*opts.V_storage;
U_storage_init = rho_liq*opts.V_storage*fnval(opts.UL_T_NO2_spline,opts.T_ext)*10^3;
             
T_wall_storage_init = opts.T_ext;
T_wall_tank_init = opts.T_ext;

initial_conditions=[m_N2O_tank_init; U_tank_init; m_N2O_storage_init; U_storage_init; T_wall_storage_init; T_wall_tank_init];   %initial vector

%Solve initial value problem for ODE
disp("-----------------------")
disp("Solving Differential Eq") 
disp("-----------------------")
disp(" ")
[t,state] = ode23s(@System_of_equations_filling_storage,t_range,initial_conditions);


m_N2O_tank = state(:,1);
U_tank = state(:,2);
m_storage = state(:,3);
U_storage = state(:,4);
T_wall_storage = state(:,5);
T_wall_tank = state(:,6);

N = length(m_N2O_tank);

T_tank = zeros(1,N);
P_tank = zeros(1,N);
x_tank = zeros(1,N);
T_storage = zeros(1,N);
P_storage = zeros(1,N);
x_storage = zeros(1,N);

mdot_in = zeros(1,N);
mdot_out = zeros(1,N);

disp("-----------------------")
disp("Post-Compute initialisation") 
disp("-----------------------")
pause(5)

m_liq_tank = (1-x_tank').*m_N2O_tank;
rho_liq_tank = fnval(opts.RhoL_T_NO2_spline,T_tank);
V_liq_tank = m_liq_tank./rho_liq_tank';

%% Post-Compute

for i=1:N
     [state_vector, T_tank_i, T_storage_i, P_tank_i, P_storage_i, x_tank_i, x_storage_i, mdot_in_i, mdot_out_i] = System_of_equations_filling_storage(state(i,:),state(i,:));
     if V_liq_tank(i)/opts.V_tank*100 <98
         P_tank(i) = P_tank_i;
         T_tank(i) = T_tank_i;
         x_tank(i) = x_tank_i;

         P_storage(i) = P_storage_i;
         T_storage(i) = T_storage_i;
         x_storage(i) = x_storage_i;
         mdot_in(i) = mdot_in_i;
         mdot_out(i) = mdot_out_i;
     else
         P_tank(i) = P_tank(i-1);
         T_tank(i) = T_tank(i-1);
         x_tank(i) = x_tank(i-1);

         P_storage(i) = P_storage(i-1);
         T_storage(i) = T_storage(i-1);
         x_storage(i) = x_storage(i-1);
         mdot_in(i) = mdot_in(i-1);
         mdot_out(i) = mdot_out(i-1);
     end
end

disp("Loss of NOx (in kg) : "+(m_storage(1)-m_storage(end)-m_N2O_tank(end)))
disp("Loss of NOx (in % of initial mass) : "+(m_storage(1)-m_storage(end)-m_N2O_tank(end))/m_storage(1)*100)
disp("Final Tank Mass (in kg) : "+m_N2O_tank(end))
Results_plots;