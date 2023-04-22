

CT_Cd = 0.5:0.05:0.95;
CT_P_tank = 59e5;          %Pa
CT_T_tank = 287;           %K

CT_mf_ox = zeros(length(CT_Cd),50);

figure(5)

for i=1:length(CT_Cd)
    [CT_Pcc, CT_mf_ox(i,:)] = critical_mf_Moody(CT_P_tank, CT_T_tank, CT_Cd(i));
    
    plot(CT_P_tank-CT_Pcc,CT_mf_ox(i,:))
    hold on
    
end



% lgd = legend("Moody", "Moody critical");
% lgd.Location = 'southeast';

xlabel("Pressure drop (Pa)")
ylabel("Mass flow (kg/s)")
title(append("MOODY Mass flow (P1=", (CT_P_tank/1e5), " bars, T1 = ", CT_T_tank, "K)")
legend("Cd = 0.5", "Cd = 0.55", "Cd = 0.6", "Cd = 0.65", "Cd = 0.7", "Cd = 0.75", "Cd = 0.8", "Cd = 0.85", "Cd = 0.9", "Cd = 0.95");