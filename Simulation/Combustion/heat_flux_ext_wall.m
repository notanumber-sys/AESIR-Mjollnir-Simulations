function [Qdot_ext_w,hcc] = heat_flux_ext_wall(V_rocket,T_ext,P_ext,T_wall)
    %This function return the flux going from the external to the wall.
    
    global opts
    
    %Geometric parameters:
    D_ext = opts.D_ext_tank;
    L = opts.L_tank;
    S = pi*D_ext*L;
    e = opts.e_tank;
    K = opts.eber_parameter;
    
    %Thermal and physical parameters
    k_alu = opts.aluminium_thermal_conductivity;
    Beta_air = 1/T_ext;             %thermic dilatation coefficient for a perfect gas
    
    
    %thermophysical properties of the air must be evaluated at Tfilm = (Text + Twall) / 2
    visc_dyn_air = py.CoolProp.CoolProp.PropsSI('V','P',P_ext,'T', (T_ext+T_wall)/2,'Air'); %Dynamic viscosity
    cp_air = py.CoolProp.CoolProp.PropsSI('C','P',P_ext,'T', (T_ext+T_wall)/2,'Air'); %Cp of air
    k_air = py.CoolProp.CoolProp.PropsSI('L','P',P_ext,'T', (T_ext+T_wall)/2,'Air'); %Conductivity of air
    rho_air = py.CoolProp.CoolProp.PropsSI('D','P',P_ext,'T', (T_ext+T_wall)/2,'Air'); %density of air
    
    
    if opts.static || V_rocket==0
        %Natural Convection
        DeltaT=T_ext-T_wall;
        G_r = rho_air^2*opts.g*L^3*Beta_air*abs(DeltaT)/(visc_dyn_air^2);
        
        Nu = 0.5*G_r^(1/4);
        hcc = Nu*k_alu/L;
    
        %so...
        h = 1/(1/hcc+0.5*e/k_alu);
        Qdot_ext_w = h*S*DeltaT;
    
    else
        %Flight mode: taking into account turbulent, compressible and supersonic
        %flow (also friction)
        
        Re=V_rocket*L*rho_air/visc_dyn_air;
        Vertex_angle=20*pi/180;%20 degrees
        hcc=(0.0071 + 0.0154*sqrt(Vertex_angle))*k_air*Re^(0.8)/L; %Eber formula for supersonic compressible flow
        
        T_st=T_ext+V_rocket^2/(2*cp_air);%stagnation temperature
        T_boundary = T_ext + K*(T_st-T_ext);%temperature inside the boudary layer taking into account friction
        
        %T_wall_ext=fzero(@(T_unknown) Wall_ext_temp_finder(T_unknown,T_boundary,h,opts), [0 1000]);
        h = 1/(1/hcc+0.5*e/k_alu);%global resistance
        DeltaT=T_boundary-T_wall;
        Qdot_ext_w = h*S*DeltaT;
        
    %     disp("h : "+h)
    %     disp("T_boundary (K) : "+T_boundary)
    %     disp("T_ext (K) : "+T_ext)
    %     disp("T_wall (K) : "+T_wall)
    %     disp("Speed (m/s) : "+V_rocket)
    end
end

function [output] = Wall_ext_temp_finder(T_ext_wall,T_boundary,h,opts)
    %EXTERNAL WALL TEMPERATURE FINDER by getting the zero of this function
    %http://dark.dk/documents/technical_notes/simplified%20aerodynamic%20heating%20of%20rockets.pdf
    
    sigma = opts.stephan_cst;
    epsilon = opts.aluminium_emissivity;
    
    
    output = h - (sigma*epsilon*T_ext_wall^4)/(T_boundary-T_ext_wall);
end
    