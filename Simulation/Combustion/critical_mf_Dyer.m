function [P_cc, mf_ox] = critical_mf_Dyer(P_tank,T_tank)
    %CRITICAL_MF_DYER Summary of this function goes here
    %   Detailed explanation goes here

    global opts
    Cd = opts.Cd;                     %Discharge coefficient
    D_inj = 2 * opts.r_inj;             %Injector diameter
    n_inj = opts.n_inj;               %Number of injector holes
    Ai = n_inj * pi * D_inj^2 / 4;
    
    P_cc = 1e5:1e5:P_tank;
    mf_SPI = zeros(1, length(P_cc));
    mf_HEM = zeros(1, length(P_cc));
    kappa = ones(1, length(P_cc));
    
    h1 = py.CoolProp.CoolProp.PropsSI('H', 'P', P_tank, 'T|liquid', round(T_tank, 2), 'NitrousOxide');   %Enthalpie massic (J/kg)
    s1 = py.CoolProp.CoolProp.PropsSI('S', 'P', P_tank, 'T|liquid', round(T_tank, 2), 'NitrousOxide');   %Enthalpie massic (J/K.kg)
    
    cp = py.CoolProp.CoolProp.PropsSI('CPMOLAR', 'P', P_tank, 'T|liquid', T_tank, 'NitrousOxide');
    cv = py.CoolProp.CoolProp.PropsSI('CVMOLAR', 'P', P_tank, 'T|liquid', T_tank, 'NitrousOxide');
    gamma = cp / cv;
    
    P_sat = fnval(opts.Psat_N2O_spline, T_tank) * 10^6;
    rho_Ox_1 = fnval(opts.RhoL_T_N2O_spline, T_tank);           %Density of Oxidizer (kg/m^3)
    
    % disp("P_sat : "+P_sat/10^5+" bars")
    for i=1:length(P_cc)
        if P_sat > P_cc(i)
            kappa(i) = sqrt((P_tank - P_cc) / (P_sat - P_cc));
        else
            kappa(i) = 1;
        end
        rho_Ox_2 = py.CoolProp.CoolProp.PropsSI('D', 'P', P_cc(i), 'Q', 1, 'NitrousOxide');     %Density of Oxidizer (kg/m^3)
        h2 = py.CoolProp.CoolProp.PropsSI('H', 'P', P_cc(i), 'S', s1, 'NitrousOxide');   %Enthalpie massic (J/kg)
        
        mf_SPI(i) = Cd * Ai * sqrt(2 * rho_Ox_1 * (P_tank - P_cc(i)));
        mf_HEM(i) = Cd * Ai * rho_Ox_2 * sqrt(2 * (h1 - h2));
        
    end
    
    %%HEM
    [critical_mf_HEM, index_critical_HEM] = max(mf_HEM);
    %     mf_HEM(1:1:index_critical_HEM)=critical_mf_HEM;
    % disp("mf_HEM_star : "+critical_mf_HEM)
    
    %%SPI
    critical_mf_SPI = Cd * Ai * sqrt(gamma * rho_Ox_1 * P_tank * (2 / (gamma + 1))^((gamma + 1) / (gamma - 1)));
    %     mf_SPI = min(critical_mf_SPI,mf_SPI);
    % disp("mf_SPI_star : "+critical_mf_SPI)
    
    
    P_star = P_tank * (2 / (gamma + 1))^(gamma / (gamma - 1));
    % disp("p_star : "+P_star/10^5+" bars")
    % disp("gamma : "+gamma)
    
    %%Total
    mf_ox = (kappa .* mf_SPI + mf_HEM) ./ (1 + kappa);
    [critical_mf, index_critical_P_cc] = max(mf_ox);
    indexes_Pcc = find(P_cc < P_star);
    mf_ox(indexes_Pcc) = mf_ox(indexes_Pcc(end));
       
    %     figure(1)
    %     plot(P_tank-P_cc,mf_ox,P_tank-P_cc,mf_SPI,P_tank-P_cc,mf_HEM)
    %     legend("Total","SPI","HEM")
    %     xlabel("Pressure drop (Pa)")
    %     ylabel("Mass flow (kg/s)")
    %     title("DYER Mass flow (P1=59 bars, T1 = 287K)")
    
    critical_P_cc = P_cc(index_critical_P_cc);
end
