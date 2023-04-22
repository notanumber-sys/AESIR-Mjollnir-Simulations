function Qdot_w_t = HeatFlux_wall_storage(P,x,T_wall,T_int)
%This function return the flux going from the wall to the tank
global opts
%Principal inputs:
DeltaT=T_wall-T_int;

%Geometric parameters:
D_int=opts.D_int_storage;
Length=opts.L_storage;
A=pi*D_int*Length;
g=opts.g;%m/s2

%thermodynamic parameters liquid:
cp_liq=py.CoolProp.CoolProp.PropsSI('C','P',P,'Q',0,'NitrousOxide');%calorific capacity of N2O
rho_liq=py.CoolProp.CoolProp.PropsSI('D','P',P,'Q',0,'NitrousOxide');%density of rho
Beta_liq=py.CoolProp.CoolProp.PropsSI('isobaric_expansion_coefficient','P',P,'Q',0,'NitrousOxide');%isobaric coefficient of N2O
kappa_liq=100.1e-3;%thermal capacity of N2O  : Wm-1K-1
L=D_int;%characteristic lenght : m
visc_liq=2.29e-5;%viscosity of N2O

%thermodynamic parameters gaz:
cp_gaz=py.CoolProp.CoolProp.PropsSI('C','P',P,'Q', 1,'NitrousOxide');%calorific capacity of N2O
rho_gaz=py.CoolProp.CoolProp.PropsSI('D','P',P,'Q', 1,'NitrousOxide');%density of rho
Beta_gaz=py.CoolProp.CoolProp.PropsSI('isobaric_expansion_coefficient','P',P,'Q', 1,'NitrousOxide');%isobaric coefficient of N2O
kappa_gaz=20.6e-3;%thermal conductivity of N2O gaz : Wm-1K-1
L=D_int;%characteristic lenght : m
visc_gaz=2.29e-5;%viscosity of N2O

%liquid phase:
A_liq=A*(1-x);%area in contact with liquid phase
c=0.021;%constant parameters given in Zimmerman;
n=2/5;%constant parameters given in Zimmerman;
Ra=cp_liq*rho_liq^2*g*Beta_liq*abs(DeltaT)*L^3/(visc_liq*kappa_liq);%Rayleigh number
Nu=c*Ra^n;%Nusset number for liquid phase
h=Nu*kappa_liq/L;%Convection capacity for liquid phase
Q_dot_in_liquid=h*A_liq*DeltaT;%Final heat flux in

%gaz phase:
A_gaz=A*x;%area in contact with gaz phase
c=0.021;%constant parameters given in Zimmerman;
n=2/5;%constant parameters given in Zimmerman;
Ra=cp_gaz*rho_gaz^2*g*Beta_gaz*abs(DeltaT)*L^3/(visc_gaz*kappa_gaz);%Rayleigh number
Nu=c*Ra^n;%Nusset number for liquid phase
h=Nu*kappa_gaz/L;%Convection capacity for liquid phase
Q_dot_in_gaz=h*A_gaz*DeltaT;%Final heat flux in

Qdot_w_t=Q_dot_in_gaz+Q_dot_in_liquid;
end

