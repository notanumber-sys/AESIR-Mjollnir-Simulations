function [state_vector, mdot_in, P_vap]  = System_of_equations_filling(t,u)

global opts
%This function gives the state vector that must be solved

m_liq = u(1);
m_vap = u(2);
U_total = u(3);


m_NO2=m_liq+m_vap;

T_ext=opts.T_ext;
r_NO2=opts.r_ox;

%% Find tank temperature:
% disp("m_NO2 : "+m_NO2)
% T_tank=Tank_Temperature_filling(U_total,m_NO2);%Searching the zero ...
T_tank=T_ext;
rho_liq=py.CoolProp.CoolProp.PropsSI('D','T',T_tank,'Q', 0,'NitrousOxide');
%% Find saturation pressure (liquid phase pressure):
disp("T_tank : "+T_tank)
P_liq = fnval(opts.Psat_NO2_spline,T_tank)*10^5; %P_tank (=saturation pressure) is computed through an interpolation of AirLiquid data

%% Find vapor fraction

x=x_vapor_filling(U_total,m_NO2,T_tank); %x_vapor computed thanks to the internal tank temperature
disp("x : "+x)

%% Find vaport volume

V_tank=opts.V_tank;
V_vap=V_tank-(1-x)*(m_vap+m_liq)/rho_liq;

%% Find vapor pressure:

rho_vap = m_vap/V_vap;
P_vap=max(1e5,rho_vap*r_NO2*T_tank);
disp("P_vap : "+P_vap/10^5+" bar")

%% Find mass flow OUT:

mdot_out=Mass_flow_outlet(P_vap,T_tank,rho_vap);%inlet mass flow
disp("mdot_out : "+mdot_out)

%% Find mass flow IN:

mdot_in=Mass_flow_inlet(P_liq,P_vap,T_tank,rho_liq,rho_vap,x);%outlet mass flow
disp("mdot_in : "+mdot_in)

%% Find mass flow evap:

%% Express the variation of mass (through conservation of mass)

dm_vapdt=-mdot_out;%*1/(1+rho_liq*r_NO2*T_tank/P_vap);
dm_liqdt=mdot_in;%-rho_liq*(r_NO2*T_tank*dm_vapdt/P_vap);

disp("dm_liqdt : "+dm_liqdt)
disp("dm_vapdt : "+dm_vapdt)

%% Express the variation internal energy:

h_outlet = py.CoolProp.CoolProp.PropsSI('H','T',T_tank,'Q', 1,'NitrousOxide');
h_inlet= py.CoolProp.CoolProp.PropsSI('H','T',T_tank,'Q', 0,'NitrousOxide');

S_inlet=opts.S_inlet;
S_outlet=opts.S_outlet;%m2

v_inlet=mdot_in/(rho_liq*S_inlet);
v_outlet=mdot_out/(rho_vap*S_outlet);

dUtotaldt=mdot_in*(h_inlet+v_inlet^2/2)-mdot_out*(h_outlet+v_outlet^2/2);

%% Express variation of volume

% dV_liqdt=dm_liqdt/rho_liq;
% dV_vapdt=dm_vapdt/rho_vap;
% 
% disp("dV_liqdt : "+dV_liqdt)
% disp("dV_vapdt : "+dV_vapdt)

%% Return the state vector:
V_liq=m_liq/rho_liq;
tank_fullness = V_liq/opts.V_tank*100;
if tank_fullness < 100
    state_vector=[dm_liqdt; dm_vapdt; dUtotaldt];
else
    state_vector=[0; 0; 0];
end

disp("rho_vap : "+rho_vap)
disp("rho_liq : "+rho_liq)
disp("V_liq : "+V_liq)
disp("V_vap : "+V_vap)

disp("Tank State : "+tank_fullness+" % full")
disp(" ")


end

