global opts
close all

e_alu=opts.e_tank;
k_alu=opts.aluminium_thermal_conductivity;
e_pad=0.23e-3;%Erik schema
k_pad=1.5;%Erik value
h_air=10;%Natural convection
e_plastic=2e-3;%to be changed
k_plastic=0.3;%average to be changed

%recovered data from simulations
h_air_ex=h_air_ext*2;
h_i_liq=h_liq;
h_i_gaz=h_gas;
T_ext=T_tank_wall;

A_cc=pi*r_cc.^2;
D_throat = opts.D_throat;
G_star = mf_throat./A_cc;
visc_throat = 3.7e-5;   %Pa.s
cp_throat = 1255;       %J/kgK
k_throat = 41.8;        %W/mK

k_para=60;
c_para=2.5e3;
rho_para=900;
e_para= opts.D_cc_int/2-r_cc;


h_cc = 0.023*(G_star.*D_throat./visc_throat).^(-0.2).*(visc_throat.*cp_throat./k_throat).^(-0.67).*G_star.*cp_throat;


%% Sensor CC

%space discretisation
N_para=20;
N_alu=6;
N_plastic=3;

tetha=2*pi;
H=0.5;
S_para=tetha*H*r_cc(1)+H*e_para(1)/N_para*[0:N_para];%dtetha=1
S_alu=tetha*H*(r_cc(1)+e_para(1)+e_alu/N_alu)*[1:N_alu];
S=[S_para S_alu];

%initial conditions  
T=284*ones(1,1+N_para+N_alu+1);
Flux=zeros(1,N_para+N_alu);
mass=zeros(1,N_para+N_alu);
c=zeros(1,N_para+N_alu);
T_save=T;
Flux_save=Flux;
i=1;
% finite volume iterations
indice_max=9145;%9145
for time=t(1:indice_max)
    
    T(1)=T_cc(i);
    T(end)=T_ext(i);
    %flux calcultations
    Flux(1)=(T(1)-T(2))/(0.5/(S(1)*h_cc(i))+0.5*e_para(i)/(k_para*S(1)*N_para))-(T(2)-T(3))*(S(2)*k_para/(e_para(i)/N_para));
    Flux(2:N_para-1)=(T(2:N_para-1)-T(3:N_para)).*(S(2:N_para-1)*k_para./(e_para(i)/N_para))-(T(3:N_para)-T(4:N_para+1)).*(S(3:N_para)*k_para./(e_para(i)/N_para));
    Flux(N_para)=(T(N_para)-T(N_para+1))*(S(N_para)*k_para/(e_para(i)/N_para))-(T(N_para+1)-T(N_para+2))/(0.5*e_alu/(k_alu*S(N_para)*N_alu)+0.5*e_para(i)/(k_para*S(N_para+1)*N_para));
    Flux(N_para+1)=(T(N_para+1) - T(N_para+2))/(0.5*e_alu/(k_alu*S(N_para+1)*N_alu) + 0.5*e_para(i)/(k_para*S(N_para+1)*N_para)) - (T(N_para+2) - T(N_para+3))*(S(N_para+2)*k_alu/(e_alu/N_alu));
    Flux(N_para+2:N_para+N_alu-1)=(T(N_para+2:N_para+N_alu-1)-T(N_para+3:N_para+N_alu)).*(S(N_para+2:N_para+N_alu-1)*k_alu./(e_alu/N_alu))-(T(N_para+3:N_para+N_alu)-T(N_para+4:N_para+N_alu+1)).*(S(N_para+3:N_para+N_alu)*k_alu./(e_alu/N_alu));
    if h_air_ex(i)<10
        Flux(N_para+N_alu)=(T(N_para+N_alu)-T(N_para+N_alu+1))*(S(N_para+N_alu)*k_alu/(e_alu/N_alu))-(T(N_para+N_alu+1)-T(N_para+N_alu+2))/(0.5/(S(N_para+N_alu+1)*10)+0.5*e_alu/(k_alu*S(N_para+N_alu+1)*N_alu));
    else
        Flux(N_para+N_alu)=(T(N_para+N_alu)-T(N_para+N_alu+1))*(S(N_para+N_alu)*k_alu/(e_alu/N_alu))-(T(N_para+N_alu+1)-T(N_para+N_alu+2))/(0.5/(S(N_para+N_alu+1)*h_air_ex(i))+0.5*e_alu/(k_alu*S(N_para+N_alu+1)*N_alu));
    end
        dt=t(i+1)-t(i);
        %finite element characteristics
        mass(1:N_para)= rho_para*(S(1:N_para)+S(2:N_para+1))*0.5*e_para(i)/N_para;
        mass(N_para+1:N_para+N_alu)= 2700*(S(N_para+1:N_para+N_alu)+S(N_para+2:N_alu+N_para+1))*0.5*e_alu/N_alu;
        c(1:N_para)=2500;
        c(N_para+1:N_para+N_alu)=1034;
        %chaleur latente de fusion
        deltah=220e3;%J/kg
        mass_burned=tetha*(r_cc(i+1)-r_cc(i))*H*(r_cc(i)+r_cc(i+1))/2;%dtheta=1
        deltaH=[rho_para*mass_burned*deltah, zeros(1,N_para+N_alu-1)];
            
        %updating T
        T(2:end-1)=T(2:end-1)+(Flux*dt-deltaH)./(mass.*c);
        %Saving ...
        T_save=[T_save; T];
        Flux_save=[Flux_save; Flux];
        i=i+1;
end

subplot(2,2,1)
plot(t(1:indice_max+1),T_save(:,2))
hold on
plot(t(1:indice_max+1),T_save(:,4))
hold on
plot(t(1:indice_max+1),T_save(:,6))
hold on
plot(t(1:indice_max+1),T_save(:,8))
hold on
plot(t(1:indice_max+1),T_save(:,10))
hold on
plot(t(1:indice_max+1),T_save(:,21))
hold on
plot(t(1:indice_max+1),T_save(:,22))
hold on
plot(t(1:indice_max+1),T_save(:,26))
hold on
plot(t(1:indice_max+1),T_ext(1,1:indice_max+1))
hold on
plot([0,t(indice_max+1)],[933,933],'r--')
title('Combution chamber wall temperature')
ylabel('Temp(K)')
xlabel('time(s)')
legend('1','2','3','4','5','6')
%legend('T_w_a_l_l ext','T_w_a_l_l int','T_p_a_r_a ext')

subplot(2,2,2)
% plot(t(1:indice_max+1),Flux_save(:,1))
% hold on
% plot(t(1:indice_max+1),Flux_save(:,2))
% hold on
plot(t(1:indice_max+1),Flux_save(:,22))
hold on
plot(t(1:indice_max+1),Flux_save(:,24))
hold on
plot(t(1:indice_max+1),Flux_save(:,26))
% hold on
% plot(t(1:indice_max+1),Flux_save(:,6))
title('Heat flux inside elements')
ylabel('W')
xlabel('time(s)')
legend('1','2','3','4','5','6')
%legend('\phi_w_a_l_l ext','\phi_w_a_l_l int','\phi_p_a_r_a ext')

subplot(2,2,3)
Flux_in=(T_save(:,1)'-T_save(:,2)')./(0.5./(S(1)*h_cc(1:indice_max+1))+0.5*e_para(1:indice_max+1)./(k_para*S(1)*N_para));

Flux_out=(T_save(:,N_para+N_alu+1)'-T_save(:,N_para+N_alu+2)')./(0.5./(S(N_para+N_alu+1)*max(10*ones(1,indice_max+1),h_air_ex(1:indice_max+1)))+0.5*e_alu/(k_alu*S(N_para+N_alu+1)*N_alu));
plot(t(1:indice_max+1),100*(Flux_in-Flux_out)./Flux_in)
title('Convergence heat flux in -  heat flux out / heat flux in')
ylabel('%')
xlabel('time(s)')
legend('%')

subplot(2,2,4)
k = find(t==10);
plot(t(1:k),T_save(1:k,end-2)-273.15)
title('Early temp at wall (10s simulation)')
ylabel('T °C')
xlabel('time(s)')
