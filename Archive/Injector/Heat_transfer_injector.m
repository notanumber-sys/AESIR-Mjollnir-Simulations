d = 1.2e-3; %m
D = 80e-3; %m
L = 12e-3;  %m
N=34;
A = N*pi*d^2/4;

W = 2.5;            %kg/s
rho = 907.8;      %kg/m3
visc = 0.0774e-3;   %Pa.s
cp = 2269.5;        %J/kg.K
k = 103e-3;        %W/m.K

delta_T_inj = 100;       %K

Re = W*d/(visc*A);
Pr = visc*cp/k;

h = k/d*0.023*Re^0.8*Pr^0.4;
disp(h)
q_sec = h*delta_T_inj;      %W/m²
q = q_sec*(N*pi*d*L+pi*D^2/4-N*pi*d^2/4);     %W
delta_T_nox = q/(cp*W);
disp(delta_T_nox)

%% Code of David

clc, clear all, close all

%This script is aimed to do a quasi-one-dimensional analysis of the
%temperature at the surface of the injector, it only takes in to 
%account the radiated heat from the combustion. But try?s to take 
%the heat that is convected in to the oxidaser, as a conservative 
%proxy for NOX air is used in these calculations and the air is 
%assumed to hold a constant temperature of 20 C.
%The combustion proses is assumed to be a spherical black body.

%Stefan-Blotzmann constant
sigma = 5.67*10^(-8);       %W/m^2 K^4

%Temperature
T_comb = 3450;              %K
T_nox = 278;             %K

%Time
burn_time = 15;             %s

%Injector
A = 0.06^(2)*pi;
m = 0.15;                   %kg
b = 0.01;                   %m

% %Contact conductance Aluminum/Air
% h = 3640;                   %W/m^2 K

%Thermal resistens
k_al = 237;                 %W/mK Al 2024-T6
k_air = 0.02514;            %W/mK Air

%Plolished Aluminum
alpha_al = 0.09;            %absorptivity
epsylon_al = 0.03;          %emissivity

% %Anodized Aluminum
% alpha_al = 0.14;          %absorptivity
% epsylon_al = 0.84;        %emissivity

%Secific heat
Cp_al = 900;                %J/kg*K

%Conductens calculations
W = 2.5;            %kg/s
rho = 907.8;      %kg/m3
visc = 2.98e-5;   %Pa.s
cp = 2269.5;        %J/kg.K
k = 103e-3;        %W/m.K
d = 1.2e-3; %m
D = 80e-3; %m
L = 12e-3;  %m
N=34;
Re = W*d/(visc*A);
Pr = 0.7309;
Nu = 0.664*Re^(1/2)*Pr^(1/3);

h_air = (k_air/b)*Nu;%En K

%Fuel grain is seen as a sphere radius 0.07 m and radius as a
%black body
r1 = 0.07;
r2 = r1 + 0.08;
G_comb = (r1^(2)*sigma*T_comb^(4))/(r2^(2));

%Initial conditions
T_plate = 287;
t = 0;
time_step = 0.01;
T = [287];
R_tot = (b/(k_al*A))+(1/(h_air*A));

while t <= burn_time
    q = alpha_al*G_comb-(epsylon_al*sigma*T_plate^(4));%W/m^2
    Q_conv = (T_plate-T_nox)/R_tot;
    Q = time_step*(q*A - Q_conv);                         %J
    dT = Q/(m*Cp_al);                          %Temperature increase
    T_plate = T_plate + dT;
    T = [T T_plate];
    t = t + time_step;
end


T_w_nox=T(15/time_step)-Q_conv*(b/(k_al*A))/time_step
-T_w_nox+T(end)
figure()
plot(0:time_step:burn_time+time_step, T-273.15)
ylabel("Tempatur, [C]")
xlabel("Time, [s]")


%%

k=200;
c=0.91e3;
rho=2700;
L=4e-3;

tau_alu=L^2*rho*c/k

k=60;
c=2.5e3;
rho=800;
L=11.9e-2;

tau_para=L^2*rho*c/k
