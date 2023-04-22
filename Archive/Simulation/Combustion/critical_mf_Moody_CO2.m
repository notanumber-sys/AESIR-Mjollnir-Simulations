function [P_cc, mf_with_crit] = critical_mf_Moody_CO2(P_tank,T_tank, Cd)
    %CRITICAL_MF_MOODY co2 version 
    %   Detailed explanation goes here

    global opts
    %     Cd = opts.Cd;                     %Discharge coefficient
    D_inj = 2*opts.r_inj;             %Injector diameter
    n_inj = opts.n_inj;               %Number of injector holes
    Ai=n_inj*pi*D_inj^2/4;
    
    P_cc = 10e5:5e5:P_tank;
    mf = zeros(1,length(P_cc));
    
    h1 = py.CoolProp.CoolProp.PropsSI('H','P',round(P_tank,2),'T', round(T_tank,2),'CarbonDioxide');   %Enthalpie massic (J/kg)
    s1 = py.CoolProp.CoolProp.PropsSI('S','P',round(P_tank,2),'T', round(T_tank,2),'CarbonDioxide');   %Enthalpie massic (J/K.kg)
    
    % P_sat_tank = fnval(opts.Psat_CO2_spline,T_tank)*10^6;
    
    %     disp("P_sat : "+P_sat_tank/10^5+" bars")
    for i=1:length(P_cc)
        rho2_l = py.CoolProp.CoolProp.PropsSI('D','P',P_cc(i),'Q', 0,'CarbonDioxide');     %Density of Oxidizer (kg/m^3)
        rho2_v = py.CoolProp.CoolProp.PropsSI('D','P',P_cc(i),'Q', 1,'CarbonDioxide');     %Density of Oxidizer (kg/m^3)
        
        hf = py.CoolProp.CoolProp.PropsSI('H','P',P_cc(i),'Q', 0,'CarbonDioxide');   %Enthalpie massic (J/kg)
        hg = py.CoolProp.CoolProp.PropsSI('H','P',P_cc(i),'Q', 1,'CarbonDioxide');   %Enthalpie massic (J/kg)
        h_fg = hg-hf;
        
        h2 = py.CoolProp.CoolProp.PropsSI('H','P',P_cc(i),'S', s1,'CarbonDioxide');   %Enthalpie massic (J/kg)
        
        x2 = (h2-hf)/h_fg;
        k = (rho2_l/rho2_v)^(1/3);
        
        if h2<=h1
            mf(i) = Cd*Ai*k/(x2+k*(1-x2)*rho2_v/rho2_l)*rho2_v*sqrt(2*(h1-h2)/(x2*(k-1)+1));
        else
            mf(i) = 0;
        end
        
    end
    
    [mf_crit, index] = max (mf);
    mf_with_crit = mf;
    mf_with_crit(1:index)=mf_crit;
    P_cc_crit = P_cc(index);
    
    %%Total
    
    %     figure(1)
    %     plot(P_tank-P_cc,mf, '--',P_tank-P_cc, mf_with_crit)
    %     lgd = legend("Moody", "Moody critical");
    %     lgd.Location = 'southeast';
        
    %     xlabel("Pressure drop (Pa)")
    %     ylabel("Mass flow (kg/s)")
    %     title("MOODY Mass flow (P1=59 bars, T1 = 287K)")
    
end


