function [state_vector, T_tank, T_storage, P_tank, P_storage, x_tank, x_storage, mdot_in_liq, mdot_out_vap]  = System_of_equations_filling_storage(t,u)

global opts

%This function gives the state vector that must be solved

m_N2O_tank = max(0,u(1));
U_tank = max(0,u(2));
m_N2O_storage = max(0,u(3));
U_storage = max(0,u(4));
T_wall_storage = u(5);
T_wall_tank = u(6);

T_ext = opts.T_ext;
P_ext = opts.P_atm_sl;



%% Find tank and storage temperature:


disp("U_tank : "+U_tank)
disp("m_N2O_tank : "+m_N2O_tank)
disp("U_storage : "+U_storage)
disp("m_N2O_storage : "+m_N2O_storage)


[T_tank, x_tank] = Tank_temperature_filling_3ph(U_tank,m_N2O_tank,opts.V_tank);
[T_storage, x_storage] =  Tank_temperature_filling_3ph(U_storage,m_N2O_storage,opts.V_storage);

m_liq_tank = (1-x_tank)*m_N2O_tank;

%% Find pressures

P_tank = fnval(opts.Psat_NO2_spline,T_tank)*10^6;
P_storage = fnval(opts.Psat_NO2_spline,T_storage)*10^6;


rho_vap_tank = fnval(opts.RhoG_T_NO2_spline,T_tank);
rho_liq_tank = fnval(opts.RhoL_T_NO2_spline,T_tank);

V_liq_tank = m_liq_tank/rho_liq_tank;

%% Find mass flow OUT of Tank:

mdot_out_vap=Mass_flow_outlet(P_tank,T_tank,rho_vap_tank);   %NO2 outlet mass flow


%% Find mass flow IN of Tank:

mdot_in_liq=Mass_flow_inlet(P_tank,P_storage,T_storage);


%% Express the variation of mass (through conservation of mass)


dm_N2O_tank_dt = mdot_in_liq - mdot_out_vap;
dm_N2O_storage_dt = -mdot_in_liq;

%% Express the variation internal energy:

h_outlet_tank = py.CoolProp.CoolProp.PropsSI('H','P',P_tank,'Q', 1,'NitrousOxide');
h_inlet_tank= py.CoolProp.CoolProp.PropsSI('H','P',P_tank,'Q', 0,'NitrousOxide');
h_inlet_storage = py.CoolProp.CoolProp.PropsSI('H','P',P_storage,'Q', 0,'NitrousOxide');

%% Heat Flux - Tank & Storage



Qdot_ext_w_storage = HeatFlux_ext_wall_storage_3ph(T_ext,P_ext,T_wall_storage,opts);
Qdot_w_t_storage = HeatFlux_wall_storage_3ph(P_storage,x_storage,T_wall_storage,T_storage);%Thermal heat flux from the wall to the tank

Qdot_ext_w_tank = HeatFlux_ext_wall_tank_3ph(T_ext,P_ext,T_wall_tank,opts);
Qdot_w_t_tank = HeatFlux_wall_tank_3ph(P_tank,x_tank,T_wall_tank,T_tank);%Thermal heat flux from the wall to the tank

m_wall_storage = opts.rho_alu*pi*((opts.D_ext_storage)^2-(opts.D_int_storage)^2)/4*opts.L_storage;
c_wall_storage = opts.alu_thermal_capacity; 
dTwall_storage_dt=(Qdot_ext_w_storage-Qdot_w_t_storage)/(m_wall_storage*c_wall_storage);

m_wall_tank = opts.rho_alu*pi*((opts.D_ext_tank)^2-(opts.D_int_tank)^2)/4*opts.L_tank;
c_wall_tank = opts.alu_thermal_capacity; 
dTwall_tank_dt=(Qdot_ext_w_tank-Qdot_w_t_tank)/(m_wall_tank*c_wall_tank);

%% Energy

dU_tank_dt=mdot_in_liq*(h_inlet_tank)-mdot_out_vap*(h_outlet_tank) + Qdot_w_t_tank;
dU_storage_dt = -mdot_in_liq*h_inlet_storage + Qdot_w_t_storage;

%% Return the state vector:

rho_vap_storage = fnval(opts.RhoG_T_NO2_spline,T_storage);
m_vap_storage = (x_storage).*m_N2O_storage';
V_vap_storage = m_vap_storage./rho_vap_storage;

tank_fullness = V_liq_tank/(opts.V_tank)*100;
storage_vapor = V_vap_storage/(opts.V_storage)*100;

if tank_fullness < 95 && storage_vapor < 99
    state_vector=[dm_N2O_tank_dt; dU_tank_dt; dm_N2O_storage_dt; dU_storage_dt; dTwall_storage_dt; dTwall_tank_dt];
%     [m_N2O_tank; U_tank; m_N2O_storage; U_storage; T_wall_storage; T_wall_tank]

% elseif storage_vapor > 99
%     dm_N2O_tank_dt = -mdot_out_vap;
%     dU_tank_dt = -mdot_out_vap*(h_outlet_tank) + Qdot_w_t_tank;
%     state_vector=[dm_N2O_tank_dt; dU_tank_dt;0;0;0;dTwall_tank_dt];
else
    state_vector=[0;0;0;0;0;0];
end

disp("x_tank : "+x_tank)
disp("x_storage : "+x_storage)

disp("T_tank : "+T_tank+" K")
disp("T_storage : "+T_storage+ " K")

disp("P_tank : "+P_tank/10^5+" bar")
disp("P_storage : "+P_storage/10^5+" bar")

disp("Tank State : "+tank_fullness+" % full")
disp(" ")
% pause(1)

end

