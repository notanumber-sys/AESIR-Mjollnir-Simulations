

L = 1.65;           %m
cp_nox = 2700;      %J/kgK
rho_nox = 828;      %kg/m^3
m_nox = 50e-3*rho_nox;  %kg

m_alu = 20;         %kg
cp_alu = 2720;      %J/kgK

T_ext = 8;          %°C    
T_tank_i = 15;      %°C
T_tank_f = 14;      %°C

T_tank_moy =(T_tank_i+T_tank_f)/2;

k_alu = 200;        %W/mK
k_nox = 17.4e-3;    %W/mK
mu_nox = 1.45e-5;   %Pa.s
beta_nox = 0.0239;  %py.CoolProp.CoolProp.PropsSI('isobaric_expansion_coefficient','P',P_N2O,'Q',0,'NitrousOxide');

Ra = cp_nox*rho_nox^2*9.81*beta_nox*(T_tank_moy-T_ext)*L^3/(mu_nox*k_nox);
Nu = 0.021*Ra^(2/5);
hi = Nu*k_nox/L; %W/m²K
he = 50;    %W/m²K (windy)
e = 10e-3;   %m

S = 2*pi*0.23/2*L+2*pi*0.23^2/4;


R_eq = (1/hi+1/he+e/k_alu)*1/S;
delta_t = (m_alu*cp_alu+m_nox*cp_nox)*R_eq*(T_tank_i-T_tank_f)/(T_tank_moy-T_ext)/60;
disp("Cooling Time (min) : "+delta_t+" min")
