function Qdot_ext_w = HeatFlux_ext_wall_storage(T_ext,P_ext,T_wall,opts)
%This function return the flux going from the wall to the tank


%Geometric parameters:
D_ext = opts.D_ext_storage;
L = opts.L_storage;
S = pi*D_ext*L;
e = opts.e_tank;

%Thermal and physical parameters
k_alu = opts.aluminium_thermal_conductivity;
Beta_air = 1/T_ext;             %thermic dilatation coefficient for a perfect gas


%thermophysical properties of the air must be evaluated at Tfilm = (Text + Twall) / 2
visc_dyn_air = py.CoolProp.CoolProp.PropsSI('V','P',P_ext,'T', T_ext,'Air'); %Dynamic viscosity
rho_air = py.CoolProp.CoolProp.PropsSI('D','P',P_ext,'T', T_ext,'Air'); %density of air

DeltaT=T_ext-T_wall;
G_r = rho_air^2*opts.g*L^3*Beta_air*abs(DeltaT)/(visc_dyn_air^2);

Nu = 0.5*G_r^(1/4);
hcc = Nu*k_alu/L;

%so...
h = 1/(1/hcc+0.5*e/k_alu);
Qdot_ext_w = h*S*DeltaT;
    
end



    