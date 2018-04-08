clear;
for x = 0: 23
hour(x+1, 1) = x;   
end

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
s_subTitle = 'Battery: ' + string(Scenario_current(1,4)) + 'kWh, Power: ' + string(Scenario_current(1,5)) + 'kW, ArrSoC: ' + string(100*Scenario_current(1,2)) + '%, ArrSoC: ' + string(100*Scenario_current(1,3)) + '%';
title( {s_title;s_subTitle},'FontWeight','Normal' )
xlabel('Hour of Day') 
ylabel('Number of vehicles') 
legend('ASAP', 'ALAP', 'Midpoint')
axis([0 24 -0 1])
print('Charging_Simulation' + string(x) ,'-dpng')
close
end

%% Run Sensitivity for Not Charging
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
s_subTitle = 'Battery: ' + string(Scenario_current(1,4)) + 'kWh, Power: ' + string(Scenario_current(1,5)) + 'kW, ArrSoC: ' + string(100*Scenario_current(1,2)) + '%, ArrSoC: ' + string(100*Scenario_current(1,3)) + '%';
title( {s_title;s_subTitle},'FontWeight','Normal' )
xlabel('Hour of Day') 
ylabel('Number of vehicles') 
legend('ASAP', 'ALAP', 'Midpoint')
axis([0 24 -0 1])
print('Not_Charging_Simulation' + string(x) ,'-dpng')
close
end


complete = 1
