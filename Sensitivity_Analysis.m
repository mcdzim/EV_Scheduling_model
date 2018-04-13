clear;
tic
for x = 0: 23
hour(x+1, 1) = x;   
end

% Are images to be saved
save_img = 0;


% %Define Fleet
% %Scenario = [fleet_Size, StartSoC, Req_SoC, BatSize, ChargeRate]
%     Scenario{1,1} = [10000, 0.5, 0.9, 40, 3];
%     Scenario{1,2} = [10000, 0.4, 0.9, 40, 3];
%     Scenario{1,3} = [10000, 0.4, 0.8, 40, 3];
%     Scenario{1,4} = [10000, 0.3, 0.8, 40, 3];
%     Scenario{1,5} = [10000, 0.3, 0.7, 40, 3];
% 
%     Scenario{1,6} = [10000, 0.5, 0.9, 20, 3];
%     Scenario{1,7} = [10000, 0.4, 0.9, 20, 3];
%     Scenario{1,8} = [10000, 0.4, 0.8, 20, 3];
%     Scenario{1,9} = [10000, 0.3, 0.8, 20, 3];
%     Scenario{1,10} = [10000, 0.3, 0.7, 20, 3];
% 
%     Scenario{1,11} = [10000, 0.5, 0.9, 40, 7];
%     Scenario{1,12} = [10000, 0.4, 0.9, 40, 7];
%     Scenario{1,13} = [10000, 0.4, 0.8, 40, 7];
%     Scenario{1,14} = [10000, 0.3, 0.8, 40, 7];
%     Scenario{1,15} = [10000, 0.3, 0.7, 40, 7];
% 
%     Scenario{1,16} = [10000, 0.5, 0.9, 80, 7];
%     Scenario{1,17} = [10000, 0.4, 0.9, 80, 7];
%     Scenario{1,18} = [10000, 0.4, 0.8, 80, 7];
%     Scenario{1,19} = [10000, 0.3, 0.8, 80, 7];
%     Scenario{1,20} = [10000, 0.3, 0.7, 80, 7];

%Sensitivity using 30 scenarios with varying charge time
for y = 1:30
    Scenario{1,y} = [10000, 0.9 - y/40 , 0.9, 40, 3];
end



%% Run Sensitivity for Charging
'charging'


ASAP_results_charging(1:24, 1) = hour;
ALAP_results_charging(1:24, 1) = hour;
MidP_results_charging(1:24, 1) = hour;

for x = 1: length(Scenario)
    

Scenario_current = Scenario{1,x};
    
%Run Simulation
simulation = ChargingModel(Scenario_current);

%Normalise to percentage of fleet
simulation = simulation / Scenario_current(1,1);


%Save Results to File
ASAP_results_charging(1:24, x+1) = simulation(1:24, 1);
ALAP_results_charging(1:24, x+1) = simulation(1:24, 2);
MidP_results_charging(1:24, x+1) = simulation(1:24, 3);
Simulation_specs(1:5, x+1) = Scenario_current;

% Plot Result
figure;
plot(hour, simulation(1:24, 1), hour, simulation(1:24, 2), hour, simulation(1:24, 3))
s_title = '{\bf\fontsize{14} Vehicles Charging vs Time of Day for Scenario ' + string(x)  + '}';
s_subTitle = 'Battery: ' + string(Scenario_current(1,4)) + 'kWh, Power: ' + string(Scenario_current(1,5)) + 'kW, ArrSoC: ' + string(100*Scenario_current(1,2)) + '%, DepSoC: ' + string(100*Scenario_current(1,3)) + '%';
title( {s_title;s_subTitle},'FontWeight','Normal' )
xlabel('Hour of Day') 
ylabel('Number of vehicles') 
legend('ASAP', 'ALAP', 'Midpoint')
axis([0 24 -0 1])
if save_img
    print('Charging_Simulation' + string(x) ,'-dpng')
end
close
end

toc
%% Run Sensitivity for Not Charging
'not charging'


ASAP_results_not_charging(1:24, 1) = hour;
ALAP_results_not_charging(1:24, 1) = hour;
MidP_results_not_charging(1:24, 1) = hour;

for x = 1: length(Scenario)
    

Scenario_current = Scenario{1,x};
    
%Run Simulation
simulation = NotChargingModel(Scenario_current);

%Normalise to percentage of fleet
simulation = simulation / Scenario_current(1,1);


%Save Results to File
ASAP_results_not_charging(1:24, x+1) = simulation(1:24, 1);
ALAP_results_not_charging(1:24, x+1) = simulation(1:24, 2);
MidP_results_not_charging(1:24, x+1) = simulation(1:24, 3);
Simulation_specs(1:5, x+1) = Scenario_current;

% Plot Result
figure;
plot(hour, simulation(1:24, 1), hour, simulation(1:24, 2), hour, simulation(1:24, 3))
s_title = '{\bf\fontsize{14} Vehicles Not Charging vs Time of Day for Scenario ' + string(x)  + '}';
s_subTitle = 'Battery: ' + string(Scenario_current(1,4)) + 'kWh, Power: ' + string(Scenario_current(1,5)) + 'kW, ArrSoC: ' + string(100*Scenario_current(1,2)) + '%, DepSoC: ' + string(100*Scenario_current(1,3)) + '%';
title( {s_title;s_subTitle},'FontWeight','Normal' )
xlabel('Hour of Day') 
ylabel('Number of vehicles') 
legend('ASAP', 'ALAP', 'Midpoint')
axis([0 24 -0 1])
if save_img
    print('Not_Charging_Simulation' + string(x) ,'-dpng')
end
close
end

toc
%% Plot MidP for varying charge times
for y = 1:10
   plot_data(1:24, y) =  MidP_results_charging(1:24, 3*y) ;
   charge_time = Scenario(1, 3*y);
   charge_time = charge_time{1,1};
   charge_time = (charge_time(1,3)-charge_time(1,2)) * charge_time(1,4) / charge_time(1,5);
   plot_name(y) = 'Daily Charge Time =' + string(charge_time) + 'h';
end

figure;
plot(hour, plot_data(1:24, 1),      hour, plot_data(1:24, 2),      hour, plot_data(1:24, 3),      hour, plot_data(1:24, 4),      hour, plot_data(1:24, 5),      hour, plot_data(1:24, 6),      hour, plot_data(1:24, 7),      hour, plot_data(1:24, 8),      hour, plot_data(1:24, 9),      hour, plot_data(1:24, 10))
s_title = '{\bf\fontsize{14} Vehicles Charging vs Time of Day}';
s_subTitle = 'Results From Sensitivity Analysis 2 of Midpoint Scheduling';
title( {s_title;s_subTitle},'FontWeight','Normal' )
xlabel('Hour of Day') 
ylabel('Number of vehicles available') 
legend(plot_name(1),     plot_name(2),     plot_name(3),     plot_name(4),     plot_name(5),     plot_name(6),     plot_name(7),     plot_name(8),     plot_name(9),     plot_name(10))
%axis([0 24 -0 1])
if save_img
    print('Charging_Results' ,'-dpng')
end
close

%% Plot MidP for varying not charge times
for y = 1:10
   plot_data(1:24, y) =  MidP_results_not_charging(1:24, 3*y) ;
   charge_time = Scenario(1, 3*y);
   charge_time = charge_time{1,1};
   charge_time = (charge_time(1,3)-charge_time(1,2)) * charge_time(1,4) / charge_time(1,5);
   plot_name(y) = 'Daily Charge Time =' + string(charge_time) + 'h';
end

figure;
plot(hour, plot_data(1:24, 1),      hour, plot_data(1:24, 2),      hour, plot_data(1:24, 3),      hour, plot_data(1:24, 4),      hour, plot_data(1:24, 5),      hour, plot_data(1:24, 6),      hour, plot_data(1:24, 7),      hour, plot_data(1:24, 8),      hour, plot_data(1:24, 9),      hour, plot_data(1:24, 10))
s_title = '{\bf\fontsize{14} Vehicles Not Charging vs Time of Day}';
s_subTitle = 'Results From Sensitivity Analysis 2 of Midpoint Scheduling';
title( {s_title;s_subTitle},'FontWeight','Normal' )
xlabel('Hour of Day') 
ylabel('Number of vehicles available') 
legend(plot_name(1),     plot_name(2),     plot_name(3),     plot_name(4),     plot_name(5),     plot_name(6),     plot_name(7),     plot_name(8),     plot_name(9),     plot_name(10))
axis([0 24 -0 1])
if save_img
    print('Not_Charging_Results' ,'-dpng')
end
close


%% complete analysis
'complete'
toc
