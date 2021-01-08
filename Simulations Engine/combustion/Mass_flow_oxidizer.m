function mf_ox = Mass_flow_oxidizer(T_tank,P_tank,P_cc)
%MASS_FLOW_FUEL calculates the mass flow of the fuel

global opts
    

    P_sat = polyval(opts.Psat_NO2_polynom,T_tank)*10^6;
    
    if P_sat>P_cc
        kapa = sqrt((P_tank-P_cc)/(P_sat-P_cc));
    else
        kapa = 1;
    end
    disp("kapa : "+kapa)

    rho_Ox_1 = polyval(opts.RhoL_T_NO2_polynom,T_tank);           %Density of Oxidizer (kg/m^3)
    rho_Ox_2 = polyval(opts.RhoL_Psat_NO2_polynom,P_cc/10^6);     %Density of Oxidizer (kg/m^3)

    h1 = py.CoolProp.CoolProp.PropsSI('H','P',P_tank,'T', round(T_tank,2),'NitrousOxide');   %Enthalpie massic (J/kg)
    s1 = py.CoolProp.CoolProp.PropsSI('S','P',P_tank,'T', round(T_tank,2),'NitrousOxide');   %Enthalpie massic (J/K.kg)
    h2 = py.CoolProp.CoolProp.PropsSI('H','P',P_cc,'S', s1,'NitrousOxide');   %Enthalpie massic (J/kg)

    Cd = opts.Cd;                     %Discharge coefficient
    D_inj = 2*opts.r_inj;             %Injector diameter
    n_inj = opts.n_inj;               %Number of injector holes


    Ai=n_inj*pi*D_inj^2/4;
    disp(P_tank)
    disp(T_tank)
    disp(h1)
    disp(s1)
    pause(10)
    critical_mf = critical_mf_DYER(P_tank,T_tank,h1,s1);
    
    mf_SPI = Cd.*Ai*sqrt(2.*rho_Ox_1.*(P_tank-P_cc));
    mf_HEM = Cd.*Ai*rho_Ox_2.*sqrt(2*(h1-h2));

%     disp("mf_SPI : "+mf_SPI)
%     disp("mf_HEM : "+mf_HEM)
    mf_ox = (kapa*mf_SPI+mf_HEM)/(1+kapa);%mf_SPI;%


end

