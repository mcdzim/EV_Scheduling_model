function result = NotChargingModel(fleet_def)
%% EV Fleet modelling using different scheduling methods
%{
Michael McDonald s1425486@sms.ed.ac.uk
BEng Hons Individual Project
Creation Date: 22/03/2018
Last edit: 13/04/2018
%}

%% Fleet Definitions
fleet_Size = fleet_def(1, 1);
StartSoC = fleet_def(1, 2);
Req_SoC = fleet_def(1, 3);
BatSize = fleet_def(1, 4);
ChargeRate = fleet_def(1, 5);


% Vehicle = Nissan Leaf
% Full electric vehicle
fleet_N = fleet_Size;  %Fleet Size 



% Produce arrival and departue times using normal data
rng('default') % For reproducibility
%Arrival Times
fleet_data(1, 1:fleet_N) = normrnd(19.16,3.62,[fleet_N, 1]);
%Departure Time
fleet_data(2, 1:fleet_N) = normrnd(10.53,3.26,[fleet_N, 1]);
%Start SoC  
fleet_data(3, 1:fleet_N) = StartSoC; % using set amount to check integral of charge hours normrnd(0.3,0.1,[fleet_N, 1]);
%Required SoC
fleet_data(4, 1:fleet_N) = Req_SoC; %  normrnd(8.5,0.5,[fleet_N, 1]);  % just set all vehicles to be planned for 90% complation charge
%Current SoC
fleet_data(5, 1:fleet_N) = 0;
%Current State
fleet_data(6, 1:fleet_N) = 0;
%Priority
fleet_data(7, 1:fleet_N) = 0;
%Battery Size (kWh)
fleet_data(8, 1:fleet_N) = BatSize;
%Charge Rate (kW)
fleet_data(9, 1:fleet_N) = ChargeRate;
%Other

%Time adjustments
%Set beginning of day to be 13:00
%not using the adjustment as of yet
time_adjust = 0;



for x = 1: fleet_N
   fleet_data(1,x) = fleet_data(1,x) - time_adjust ; 
   
   %As day is continuous need to move times greater tham 24 to next morning
   if  (fleet_data(1,x) >= 24)
      fleet_data(1,x) = fleet_data(1,x) - 24 ;
   end
   if  (fleet_data(2,x) >= 24)
      fleet_data(2,x) = fleet_data(2,x) - 24 ;
   end
   
   %If time below 0 then add 24 hours
   if  (fleet_data(1,x) <= 0)
      fleet_data(1,x) = fleet_data(1,x) + 24 ;
   end
   if  (fleet_data(2,x) <= 0)
      fleet_data(2,x) = fleet_data(2,x) + 24 ;
   end
   
end
clear time_adjust;

% %plot arrival and departure times histogram
% figure1 = figure;
% histogram(fleet_data(1,:),'BinWidth',0.5)
% hold on
% histogram(fleet_data(2,:),'BinWidth',0.5)
% hold off
% legend('Arrival', 'Departure')
% title('Arrival and Departure distribution of fleet')
% xlabel('Hour of Day') 
% ylabel('Number of Vehicles') 


%% Run Simulation for Charge as Soon as Possible

% Charge upon arrival  
fleet_ASAP= Charge_ASAP(fleet_data); 

%% Run Simulation for Charge as Late as Possible

% Charge upon arrival  
fleet_ALAP = Charge_ALAP(fleet_data); 


%% Run Simulation for Midpoint between charge as soon and as late as possible
%split fleet in half and operate each half independantly

% Charge upon arrival  
fleet_MidP = Charge_MidP(fleet_data); 


%% Run Simulation for using Priority Algorithm

% Charge based on priority algorithm  
% fleet_Priority = Priority_Calc(fleet_data); 


%% Plot Results

% % % Plots of ASAP, ALAP and Midpoint 
% figure;
% plot(fleet_ASAP(1:24, 1), fleet_ASAP(1:24, 6), fleet_ASAP(1:24, 1), fleet_ASAP(1:24, 3), fleet_ALAP(1:24, 1), fleet_ALAP(1:24, 3), fleet_MidP(1:24, 1), fleet_MidP(1:24, 3))
% title('Vehicles Charging vs Time of Day')
% xlabel('Hour of Day') 
% ylabel('Number of vehicles') 
% legend('Vehicles at home','ASAP Scheduling', 'ALAP Scheduling', 'Midpoint Scheduling')
% 
% figure;
% plot(fleet_ASAP(1:24, 1), fleet_ASAP(1:24, 6), fleet_ASAP(1:24, 1), fleet_ASAP(1:24, 4), fleet_ALAP(1:24, 1), fleet_ALAP(1:24, 4), fleet_MidP(1:24, 1), fleet_MidP(1:24, 4))
% title('Vehicles Plugged in Not Charging vs Time of Day')
% xlabel('Hour of Day') 
% ylabel('Number of vehicles') 
% legend('Vehicles at home', 'ASAP Scheduling', 'ALAP Scheduling', 'Midpoint Scheduling')



% % % Plots of Priority and Midpoint 
% figure;
% plot(fleet_Priority(1:24, 1), fleet_Priority(1:24, 6), fleet_Priority(1:24, 1), fleet_Priority(1:24, 3), fleet_MidP(1:24, 1), fleet_MidP(1:24, 3))
% title('Vehicles Charging vs Time of Day')
% xlabel('Hour of Day') 
% ylabel('Number of vehicles') 
% legend('Vehicles at home', 'Priority Scheduling', 'Midpoint Scheduling')
% 
% figure;
% plot(fleet_Priority(1:24, 1), fleet_Priority(1:24, 6), fleet_Priority(1:24, 1), fleet_Priority(1:24, 4), fleet_MidP(1:24, 1), fleet_MidP(1:24, 4))
% title('Vehicles Plugged in Not Charging vs Time of Day')
% xlabel('Hour of Day') 
% ylabel('Number of vehicles') 
% legend('Vehicles at home', 'Priority Scheduling', 'Midpoint Scheduling')


% figure3 = figure;
% plot(FleetStatus(1:24, 1), test_vehicle(1:24, 6))
% title('Vehicles SoC')
% xlabel('Hour of Day') 
% ylabel('SoC') 

charging_result(1:24, 1) = fleet_ASAP(1:24, 3);
charging_result(1:24, 2) = fleet_ALAP(1:24, 3);
charging_result(1:24, 3) = fleet_MidP(1:24, 3);

not_charging_result(1:24, 1) = fleet_ASAP(1:24, 4);
not_charging_result(1:24, 2) = fleet_ALAP(1:24, 4);
not_charging_result(1:24, 3) = fleet_MidP(1:24, 4);


%Change result below to swap between charging and not charging
%result = charging_result;
result = not_charging_result;

end