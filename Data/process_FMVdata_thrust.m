%2022-12-06 Kaibin Wen
% Filter the data from the thrust profile, use a simple median filter or 
% average filter with window size 500. The raw data from FMV should be
% processed by converter.py first

close all

%import results of ht2-1
opts = detectImportOptions('./ht-2a1/out_filetest001.txt');
dataFMV_raw_1 = readtable('./ht-2a1/out_filetest001.txt',opts);

%import results of ht2-2
dataFMV_raw_2 = readtable('./ht-2a2/out_filetest002.txt',opts);

%% Process data of ht2-1
t_1 = dataFMV_raw_1.Time;
f1_1 = dataFMV_raw_1.P1;
f1_2 = dataFMV_raw_1.P2;
fs = 1/(t_1(2)-t_1(1)); % sampling frequency
 


%find burn time
for i = 1: length(t_1)
    if f1_1(i)>0.15
        burntime_indx = i;
        break
    else
        continue
    end
end
indx = i-50000:i+2000000; %the plot range
% filtering
windowSize = 500; 
b = (1/windowSize)*ones(1,windowSize);
a = 1;

f1_1_filter_ave = filter(b,a,f1_1); %Average filter
f1_1_filter_med = medfilt1(f1_1,500); % Median filter

f1_2_filter_ave = filter(b,a,f1_2); %Average filter
f1_2_filter_med = medfilt1(f1_2,500); % Median filter

%% Process data of ht2-2
t_2 = dataFMV_raw_2.Time;
f2_1 = dataFMV_raw_2.P1;
f2_2 = dataFMV_raw_2.P2;
fs = 1/(t_2(2)-t_2(1)); % sampling frequency
 


%find burn time
for i = 1: length(t_2)
    if f2_1(i)>0.15
        burntime_indx = i;
        break
    else
        continue
    end
end
indx2 = i-50000:i+2000000; %the plot range
% filtering
windowSize = 500; 
b = (1/windowSize)*ones(1,windowSize);
a = 1;

f2_1_filter_ave = filter(b,a,f2_1); %Average filter
f2_1_filter_med = medfilt1(f2_1,500); % Median filter

f2_2_filter_ave = filter(b,a,f2_2); %Average filter
f2_2_filter_med = medfilt1(f2_2,500); % Median filter

%% plotting
figure(1)
subplot(211)
plot(t_2(indx2),f2_1(indx2))
hold on
plot(t_2(indx2),f2_1_filter_med(indx2))
%plot(t(indx),f1_1_filter_ave(indx))
hold off
ylabel('F_1/kN')
legend('raw data','filtered data')
title('HT2-1 Thrust protile')
subplot(212)
plot(t_2(indx2),f2_2(indx2))
hold on
plot(t_2(indx2),f2_2_filter_med(indx2))
xlabel('t/s')
ylabel('F_2/kN')


figure(2)
subplot(211)
plot(t_2(indx),f1_1(indx))
hold on
plot(t_1(indx),f1_1_filter_med(indx))
%plot(t(indx),f1_1_filter_ave(indx))
hold off
ylabel('F_1/kN')
legend('raw data','filtered data')
title('HT2-2 Thrust protile')
subplot(212)
plot(t_1(indx),f1_2(indx))
hold on
plot(t_1(indx),f1_2_filter_med(indx))
xlabel('t/s')
ylabel('F_2/kN')
