%% Sensor measurments calculations

global opts

e_alu=opts.e_tank;
k_alu=opts.aluminium_thermal_conductivity;
e_pad=0.23e-3;%Erik schema
k_pad=1.5;%Erik value
h_air=10;%Natural convection
e_plastic=2e-3;%to be changed
k_plastic=0.3;%average to be changed

%recovered data from simulations
h_air_ex=h_air_ext;
h_i_liq=h_liq;
h_i_gaz=h_gas;
T_ext=T_tank_wall';

%% Sensor Vent

P_sensor_vent = P_tank;
T_sensor_vent = T_tank;

%% Sensor Tank

x_fill = m_ox_total./(opts.V_tank*opts.rho_ox);
L = opts.L_tank;

R_in_gaz = 1./h_gas+e_alu/k_alu+e_pad/k_pad;
R_in_liq = 1./h_liq+e_alu/k_alu+e_pad/k_pad;
R_ex = 1./h_air+e_plastic/k_plastic+1./h_air_ex;

%Top 3/4
i_top = find(x_fill<3/4,1);
R_in_top = [R_in_liq(1:i_top) R_in_gaz(i_top+1:end)];

%Mid 2/4
i_mid = find(x_fill<2/4,1);
R_in_mid = [R_in_liq(1:i_mid) R_in_gaz(i_mid+1:end)];

%Low 1/4
i_low = find(x_fill<1/4,1);
R_in_low = [R_in_liq(1:i_low) R_in_gaz(i_low+1:end)];

T_sensor_tank_top = T_tank + R_in_top./(R_in_top+R_ex).*(T_ext - T_tank);
T_sensor_tank_mid = T_tank + R_in_mid./(R_in_mid+R_ex).*(T_ext - T_tank);
T_sensor_tank_bot = T_tank + R_in_low./(R_in_low+R_ex).*(T_ext - T_tank);

% deltaT_tank=T_tank-T_ext;
% Surface_Heat_Flux_Tank=deltaT_tank./(1./(x*h_i_liq+(1-x)*h_i_gaz)+e_alu/k_alu+1./h_air_ex);
% T_sensor_tank_top=T_tank-Surface_Heat_Flux_Tank*(1./h_i_gaz+e_alu/k_alu+e_pad/k_pad);
% T_sensor_tank_mid=T_tank-Surface_Heat_Flux_Tank*(1./h_i_liq+e_alu/k_alu+e_pad/k_pad);
% T_sensor_tank_bot=T_tank-Surface_Heat_Flux_Tank*(1./h_i_liq+e_alu/k_alu+e_pad/k_pad);
%% Sensor kastrullan

e_pipe=(13.5-11)*10^-3;
k_pipe=50.2; %20°C for steel
R_in_k = 1./h_liq+e_pipe/k_pipe+e_pad/k_pad;
R_ex_k = 1./h_air+e_plastic/k_plastic+1./h_air_ex;

P_sensor_kast_top = P_tank;%+g*z*h

T_sensor_kast_top = T_tank + R_in_k./(R_in_k+R_ex_k).*(T_ext - T_tank);
T_sensor_kast_bot = T_tank + R_in_k./(R_in_k+R_ex_k).*(T_ext - T_tank);


%% Sensor Injector

Pdrop=1e5;%Pa
P_sensor_inj = P_tank-Pdrop;

%Injector
A_inj_plate = (opts.r_inj_plate)^(2)*pi;
A_pre_cc = pi*opts.D_cc_int*opts.L_pcc;

m_inj = opts.mass_inj;          %kg
m_pre_cc = opts.mass_pcc;

%Thermal resistens
k_al = opts.aluminium_thermal_conductivity;                 %W/mK Al 2024-T6
k_air = opts.air_thermal_conductivity;                           %W/mK Air

%Plolished Aluminum
alpha_al = opts.aluminium_absorbitivity;        %absorptivity
epsylon_al = opts.aluminium_emissivity;         %emissivity
Cp_al = opts.alu_thermal_capacity;              %calorific capacity


rho_Nox_cc = fnval(opts.RhoG_P_NO2_spline, P_cc);      %kg/m3

Re = mf_ox*opts.L_pcc/(opts.visc_nox*A_inj_plate);
Pr = opts.visc_nox*opts.calorific_capacity_nox/opts.thermal_conductivity_nox;
Nu = 0.664*Re.^(1/2)*Pr^(1/3);
h_nox_cc = (opts.thermal_conductivity_nox/opts.e_inj)*Nu;


%Stefan-Blotzmann constant
sigma = 5.67*10^(-8);       %W/m^2 K^4
%Fuel grain is seen as a sphere radius 0.07 m and radius as a
%black body
r1 = 0.07;
r2 = r1 + 0.08;
G_comb = (r1^(2)*sigma*T_cc.^(4))/(r2^(2));

%Initial conditions
T_plate = 287;
T_pre_cc = 287;

t_plate = 0;
T_sensor_inj = [287];

T_sensor_inj_top = [287];
T_sensor_inj_bot = [287];
T_sensor_cc_top = [287];

R_tot_inj = (opts.e_inj/(k_al*A_inj_plate))+(1./(h_nox_cc*A_inj_plate));
R_tot_pre_cc = (opts.e_cc/(k_al*A_pre_cc)+(1./(h_nox_cc*A_pre_cc)));

for i=1:length(t)-1
    time_step = t(i+1)-t(i);
    q_rad_inj = alpha_al*G_comb(i)-(epsylon_al*sigma*T_plate^(4)); %W/m^2
    Q_conv_inj = (T_plate-T_tank(i))/R_tot_inj(i);                  %W
    E_inj = time_step*(q_rad_inj*A_inj_plate - Q_conv_inj);             %J
    dT_inj = E_inj/(m_inj*Cp_al);                                       %K - Temperature increase
    T_plate = T_plate + dT_inj;
    T_sensor_inj = [T_sensor_inj T_plate];
    T_sensor_inj_top = [T_sensor_inj_top    T_plate+q_rad_inj*opts.e_inj/2/k_al];
    T_sensor_inj_bot = [T_sensor_inj_bot    T_plate+Q_conv_inj/A_inj_plate*opts.e_inj/2/k_al];
    
    %Pre-combustion chamber
    q_rad_pre_cc = alpha_al*G_comb(i)-(epsylon_al*sigma*T_pre_cc^(4));
    Q_conv_pre_cc = (T_pre_cc-T_ext(i))/R_tot_pre_cc(i);                  %W
    E_pre_cc = time_step*(q_rad_pre_cc*A_pre_cc - Q_conv_pre_cc);
    dT_pre_cc = E_pre_cc/(m_pre_cc*Cp_al); 
    T_pre_cc = T_pre_cc + dT_pre_cc;
    T_sensor_cc_top = [T_sensor_cc_top      T_pre_cc+Q_conv_pre_cc/A_pre_cc*opts.e_cc/2/k_al];
end



%% Sensor CC

P_sensor_CC = P_cc;

%top
T_sensor_CC_top = T_sensor_cc_top;

%mid
A_cc=pi*r_cc'.^2;
D_throat = opts.D_throat;
G_star = mf_throat./A_cc;
visc_throat = 3.7e-5;   %Pa.s
cp_throat = 1255;       %J/kgK
k_throat = 41.8;        %W/mK

    %parafin
k_para=60;
c_para=2.5e3;
rho_para=800;
e_para= opts.D_cc_int/2-r_cc';

h_cc = 0.023*(G_star.*D_throat./visc_throat).^(-0.2).*(visc_throat.*cp_throat./k_throat).^(-0.67).*G_star.*cp_throat;

R_in = 1./h_cc+e_para/k_para+e_alu/k_alu+e_pad/k_pad;%interior resistance
R_ex = e_plastic/k_plastic+1./h_air_ex;%Exterior resistance

T_sensor_CC_fuel = T_cc + R_in./(R_in+R_ex).*(T_ext - T_cc);%tension bridge :D
    
deltaT=T_cc-T_ext;
Surface_Heat_Flux_CC=deltaT./(1./h_cc+e_para/k_para+e_alu/k_alu+1./h_air_ex);

% figure(109)
% plot(t(1:2700),Surface_Heat_Flux_CC(1:2700))

T_sensor_CC_fuel=T_cc-1.5*Surface_Heat_Flux_CC.*(1./h_cc+e_para/k_para+e_alu/k_alu+e_pad/k_pad);
%bot
T_sensor_CC_bot = T_cc-Surface_Heat_Flux_CC.*(1./h_cc+e_alu/k_alu+e_pad/k_pad);


%% Sensor Nozzle Throat

e_graph_throat = 33e-3; %m
e_al_throat_in = 10e-3; %m
e_al_throat_ex = 10e-3; %m
k_graph = 70;           %W/mK

D_throat = opts.D_throat;
A_throat = pi*D_throat^2/4;
G_star = mf_throat/A_throat;
visc_throat = 3.7e-5;   %Pa.s
cp_throat = 1255;       %J/kgK
k_throat = 41.8;        %W/mK

h_fg = 0.023*(G_star.*D_throat./visc_throat).^(-0.2).*(visc_throat.*cp_throat./k_throat).^(-0.67).*G_star.*cp_throat;


R_in_star = 1./h_fg+e_graph_throat/k_graph+e_al_throat_in/k_al;
R_ex_star = e_al_throat_ex/k_al + e_plastic/k_plastic+1./h_air_ex;

gamma = opts.gamma_combustion_products;
T_star = T_cc./((gamma+1)/2);
T_sensor_throat = T_star + R_in_star./(R_in_star+R_ex_star).*(T_ext - T_star);

