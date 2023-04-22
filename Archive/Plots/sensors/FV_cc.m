%function T_save = FV_cc(t,r_cc,mf_throat,A_cc,T_cc,T_ext,e_alu,k_alu,h_air_ex)
close all
%classic parameters
    global opts
    A_cc=pi*r_cc'.^2;
    D_throat = opts.D_throat;
    G_star = mf_throat./A_cc;
    visc_throat = 3.7e-5;   %Pa.s
    cp_throat = 1255;       %J/kgK
    k_throat = 41.8;        %W/mK

    k_para=60;
    c_para=2.5e3;
    rho_para=800;
    e_para= opts.D_cc_int/2-r_cc';
    H=0.5;
    S_para=H*r_cc(1)+H*e_para(1)/5*[0:5];%H=0.1
    S_alu=H*(r_cc(1)+e_para(1)+e_alu/5)*[1:5];
    S=[S_para S_alu];
    h_cc = 0.023*(G_star.*D_throat./visc_throat).^(-0.2).*(visc_throat.*cp_throat./k_throat).^(-0.67).*G_star.*cp_throat;


%initial conditions  
    T=284*ones(1,12);
    Flux=zeros(1,10);
    mass=zeros(1,10);
    c=zeros(1,10);
    T_save=T;
    Flux_save=Flux;
    i=1;
    % finite volume iterations
    for time=t(1:8230)'
        T(1)=T_cc(i);
        T(12)=T_ext(i);
        Flux(1)=(T(1)-T(2))/(0.5/(S(1)*h_cc(i))+0.1*e_para(i)/(k_para*S(1)))-(T(2)-T(3))*(S(2)*k_para/(e_para(i)/5));
        Flux(2:4)=(T(2:4)-T(3:5)).*(S(2:4)*k_para./(e_para(i)/5))-(T(3:5)-T(4:6)).*(S(3:5)*k_para./(e_para(i)/5));
        Flux(5)=(T(5)-T(6))*(S(5)*k_para/(e_para(i)/5))-(T(6)-T(7))/(0.1*e_alu/(k_alu*S(6))+0.1*e_para(i)/(k_para*S(6)));
        Flux(6)=(T(6)-T(7))/(0.1*e_alu/(k_alu*S(6))+0.1*e_para(i)/(k_para*S(6)))-(T(7)-T(8))*(S(7)*k_alu/(e_alu/5));
        Flux(7:9)=(T(7:9)-T(8:10)).*(S(7:9)*k_alu./(e_alu/5))-(T(8:10)-T(9:11)).*(S(8:10)*k_alu./(e_alu/5));
        if h_air_ex(i)<10
            Flux(10)=(T(10)-T(11))*(S(10)*k_alu/(e_alu/5))-(T(11)-T(12))/(0.5/(S(11)*10)+0.1*e_alu/(k_alu*S(11)));
        else
            Flux(10)=(T(10)-T(11))*(S(10)*k_alu/(e_alu/5))-(T(11)-T(12))/(0.5/(S(11)*h_air_ex(i))+0.1*e_alu/(k_alu*S(11)));
        end
        dt=t(i+1)-t(i)
        mass(1:5)= 900*(S(1:5)+S(2:6))*0.5*e_para(i)/5;
        mass(6:10)= 2700*(S(6:10)+S(7:11))*0.5*e_alu/5;
        c(1:5)=2500;
        c(6:10)=1034;
        
        T(2:end-1)=T(2:end-1)+Flux*dt./(mass.*c);
        T_save=[T_save; T];
        Flux_save=[Flux_save; Flux];
        i=i+1;
       
    end
%end

plot(t(1:8231),T_save(:,10))
hold on
plot(t(1:8231),T_save(:,7))
hold on
% plot(t(1:8231),T_save(:,2))
title('Combution chamber wall temperature')
ylabel('Temp(K)')
xlabel('time(s)')
legend('T_w_a_l_l ext','T_w_a_l_l int','T_p_a_r_a ext')