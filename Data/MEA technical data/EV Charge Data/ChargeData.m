%% Script Designed to Load and analyse EV charge Data as file is too large to be analysed efficiently in Excel


%% Load in Data File

clear;
Datafile = 'EVChargeData(WC07).csv';
Datafile = 'EVChargeData.csv';

%load file from filename "DataFile" as file "EVChargeData"
EVChargeDataLoad;

%% Create individual Variables for Data Points

% dataLength = 1000;  %used for testing with small sample
dataLength = length(EVChargeData{1,1});
data_ParticipantID = EVChargeData{1, 1}([1:dataLength],1);
data_BatteryChargeStartDate = [EVChargeData{1, 2}([1:dataLength],1)];
data_BatteryChargeStopDate = [EVChargeData{1, 3}([1:dataLength],1)];
data_StartingSOC = [EVChargeData{1, 4}([1:dataLength],1)];
data_EndingSOC = [EVChargeData{1, 5}([1:dataLength],1)];
clearvars Datafile EVChargeData;

%% Calculate Additional Variables

data_ChargeEnergy = data_EndingSOC - data_StartingSOC;
data_ChargeTime = data_BatteryChargeStopDate - data_BatteryChargeStartDate;
data_chargePower = hours(data_ChargeTime)./data_ChargeEnergy;
data_chargePower(data_chargePower == Inf) = NaN;


%% Compare with time of day
hourArrive_Power = zeros(dataLength, 24);

for x = 1:dataLength
  
  hourArrive_Power(x, hour(data_BatteryChargeStartDate(x,1))+1) = data_chargePower(x, 1);
    
end

time(1, 23) = 0;
ToD_Power(1, 23) = 0;
for x = 1:24
  time(x,1) = x-1;

  ToD_Power(x, 1) = mean(hourArrive_Power(1:dataLength, x), 'omitnan');  
end

%% Plot Results

figure1 = figure;
plot(time, ToD_Power)
legend("Average Charge Rate for arrival time")



