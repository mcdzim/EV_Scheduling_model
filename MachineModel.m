%% EV Fleet modelling using different scheduling methods
%{
Michael McDonald s1425486@sms.ed.ac.uk
BEng Hons Individual Project
Creation Date: 22/03/2018
Last edit: 23/03/2018
%}
clear;

% %%  Load Data From File
% csvName = 'LoadData.csv' ;  % recorded data file from test
% DataFileRead = csvread(csvName);
% 
% %Load in whole file
% t_start = 1;
% t_end = length(DataFileRead);
% 
% 
% D_time = DataFileRead(t_start:t_end, 1);
% D_arrival = DataFileRead(t_start:t_end, 2);
% D_departure = DataFileRead(t_start:t_end, 3);
% D_location = DataFileRead(t_start:t_end, 4);
% D_chargeIn = DataFileRead(t_start:t_end, 5);
% clear DataFileRead;
% 
% % %plot Loaded Data
% % figure1 = figure;
% % plot(D_time, D_arrival, D_time, D_departure, D_time, D_location)
% % title('Data Loaded in')
% % xlabel('Hour of Day') 
% % ylabel('Probability') 
% % legend('P arrival','P departure','P at home (User1)') 

%% Fleet Definitions

% Vehicle = Nissan Leaf
% Full electric vehicle
fleet_N = 10000;  %Fleet Size 
fleet_P = 3; %Fleet Power per vehicle (kW) 
fleet_E = 40; %Fleet Energy per vehicle battery (kWh)
fleet_R = 270; %Fleet vehicle range (km)



% Produce arrival and departue times using normal data
rng('default') % For reproducibility
%Arrival Times
fleet_data(1, 1:fleet_N) = normrnd(19.16,3.62,[fleet_N, 1]);
%Departure Time
fleet_data(2, 1:fleet_N) = normrnd(10.53,3.26,[fleet_N, 1]);
%Current SoC - Set as gaussian distribution for mixed arrival times
fleet_data(3, 1:fleet_N) = normrnd(5,1,[fleet_N, 1]);
%Required SoC
fleet_data(4, 1:fleet_N) = 9; %  normrnd(8.5,0.5,[fleet_N, 1]);  % just set all vehicles to be planned for 90% complation charge
%Priority Algorithm
fleet_data(5, 1:fleet_N) = 0;
%Current State
fleet_data(5, 1:fleet_N) = 0;


%As day is continuous need to move times greater tham 24 to next morning
for x = 1: fleet_N
   if  (fleet_data(1,x) >= 24)
      fleet_data(1,x) = fleet_data(1,x) - 24 ;
   end
   if  (fleet_data(2,x) >= 24)
      fleet_data(2,x) = fleet_data(2,x) - 24 ;
   end
end


%% Begin Simulation
vehiclesHome(24, 6) = 0;

for hour = 0:23;
   % rerun priority list calculation
   fleet_data = Vehicle_home(fleet_data, hour);
   
   
   % charge priority vehicles
   
   %adjust current SoC
   
   
   
   
 
  %Count vehicles in different states 
  vehiclesHome(hour+ 1, 1) = hour;
  % State 0
  vehiclesHome(hour+ 1, 2) = sum(fleet_data(6, 1:fleet_N)==0);
  % State 1
  vehiclesHome(hour+ 1, 3) = sum(fleet_data(6, 1:fleet_N)==1);
  % State 2
  vehiclesHome(hour+ 1, 4) = sum(fleet_data(6, 1:fleet_N)==2);
  % State -1
  vehiclesHome(hour+ 1, 5) = sum(fleet_data(6, 1:fleet_N)==-1);
  % All vehicles at home
  vehiclesHome(hour+ 1, 6) =   vehiclesHome(hour+ 1, 3) +  vehiclesHome(hour+ 1, 4) +  vehiclesHome(hour+ 1, 5);

end

figure2 = figure;
plot(vehiclesHome(1:24, 1), vehiclesHome(1:24, 6))
title('Vehicles at Home')
xlabel('Hour of Day') 
ylabel('Number of vehicles') 

