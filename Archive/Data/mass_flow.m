close all
data1 = load('Datasets/HT-2/ht21.mat');
data2 = load('Datasets/HT-2/ht22.mat');
%% process mass
% HT2-1
time1 = data1.data.TANK_WEIGHT(:,1);
weight1 = data1.data.TANK_WEIGHT(:,2);
%splinetool(time,weight)
spline1_1 = csapi(time1,weight1); %cubic spline fit of the tank mass
spline1_2 = csaps(time1,weight1); %cubic spline smooth fit of the tank mass

%HT2-2
time2 = data2.data.TANK_WEIGHT(:,1);
weight2 = data2.data.TANK_WEIGHT(:,2);

spline2_1 = csapi(time2,weight2); %cubic spline fit of the tank mass
spline2_2 = csaps(time2,weight2,0.8); %cubic spline smooth fit of the tank mass

figure(1)
plot(time1, weight1, 'ro')
hold on
fnplt(spline1_2, 'r-')
xlabel('Time/s');
ylabel('Tank mass/kg');
legend('HT2-1 Data points', 'HT2-1 Spline fit','Location', 'northwest');

figure(3)
plot(time2, weight2, 'b*')
hold on
fnplt(spline2_2, 'b-')
xlabel('Time/s');
ylabel('Tank mass/kg');
legend('HT2-2 Data points', 'HT2-2 Spline fit','Location', 'northwest');

%% Differentiate mass to get mass flow
weightprime1 = fnder(spline1_2); %first order derivative of tank mass HT2-1
weightprime2 = fnder(spline2_2); %HT2-2
figure(2)
fnplt(weightprime1, 'r-');
hold on
%fnplt(weightprime2, 'b-');
xlabel('Time/s');
ylabel('Mass flow/(kg/s)');
%legend('HT2-1', 'HT2-2');


%% 
figure(4)
plot(data2.data.TANK_WEIGHT(:,1), data2.data.TANK_WEIGHT(:,2))

