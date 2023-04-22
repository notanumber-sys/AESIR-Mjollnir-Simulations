function [d2xdt2, d2ydt2] = eq_of_motion(Tf,m_ox,m_fuel,y,vx,vy,speed_of_sound,rho_ext)

    global opts

    %EQOFMOTION Summary of this function goes here
    %   Detailed explanation goes here
    
    
    v=sqrt(vx.^2+vy.^2);
    m = opts.dry_mass+m_ox+m_fuel;
    angle = opts.launch_angle;
    Cd = drag_coefficient_model(v, speed_of_sound);
    frontal_area = opts.surface;
    
    D= Cd .* 0.5 .* rho_ext .* v.^2 .* frontal_area;
    
    g=gravity_model(y);
    
    
    if opts.static %static fire
        d2xdt2 = 0;
        d2ydt2 = 0;
    else %flight condition
        if v<10 || y<0
            Dx = 0;
            Dy = 0;
            Tfx = Tf.*cosd(angle);
            Tfy = Tf.*sind(angle);
        else
            Dx = D.*vx./v;
            Dy = D.*vy./v;
            Tfx = Tf.*vx./v;
            Tfy = Tf.*vy./v;
        end
    
        d2xdt2=(Tfx-Dx)./m;
        d2ydt2=-g+(Tfy-Dy)./m;
        
        %     disp("Drag (N) : "+D)
        %     disp("Dx : "+Dx)
        %     disp("Dy : "+Dy)  
        %     disp("Thrust (N) : "+Tf)
        %     disp("a_x (g) : "+d2xdt2./g)
        %     disp("a_y (g) : "+d2ydt2./g)  
    end
end
