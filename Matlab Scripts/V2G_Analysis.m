clear;
%Run simulation for every hour of day
%Date Created: 14-04-2018
%Date last edited: 14-04-2018
tic;

%% Simulation Details			
% DSR_hour is the hour the service is called upon
% DSR_direction is the service required: 0= no service, 1= turn down, 2=turn up
% Duration of Service in Hours (works in hour blocks so use integer values)
DSR_hour = 1; %Will be changed in loop below
DSR_duration = 1;
fleet_Size = 5000;
ChargeRate = 3;
StartSoC = 0.5; 
Req_SoC = 0.89;
BatSize = 40;
results_hours = linspace(0,23,24);
save_img = 1;

%% Run Simulation for Demand Turn Down every hour of the day
DSR_direction = 1;
for x = 1:24
	DSR_hour = x;
	DSR_details = [DSR_hour, DSR_direction, DSR_duration, ChargeRate, fleet_Size, StartSoC, Req_SoC, BatSize];
	sim_results = Charge_V2G(DSR_details);

	%sim_results = 24:8
	%sim_results(:, 1) = hour of day
	%sim_results(:, 2) = Vehicles at Home
	%sim_results(:, 3) = Vehicles Charging     - No DSR
	%sim_results(:, 4) = Vehicles Not Charging - No DSR
	%sim_results(:, 5) = Vehicles was Charging     - Now Injecting
	%sim_results(:, 6) = Vehicles was Not Charging - Now Injecting
	%sim_results(:, 7) = Vehicles was Charging     - Now Charging    --- This is a useless state but left in to keep symmetry
	%sim_results(:, 8) = Vehicles was Not Charging - Now Charging



	%Power Demand = Charging[3,7,8] - Injecting[5,6] 

	%% Save Results For Evaluation
	%Simulation Details
	sim_details(x, :) = DSR_details();

	%Simulation Results
	sim_vehicles_home(:, 1) = sim_results(:, 2);
	sim_charging(:, 1) = sim_results(:, 3);
	sim_not_charging(:, 1) = sim_results(:, 4);

	%Demand Turn Down = 2*(Charge -> Inject[5]) + 1*(Not-Charge -> Inject[6])
	%Demand Turn Up   = 0*(Charge -> Charge[7]) + 1*(Not-Charge -> Charge[8])
	sim_DTD(:, 1) = 2*sim_results(:, 5) + 1*sim_results(:, 6) ;
	sim_DTU(:, 1) = 0*sim_results(:, 7) + 1*sim_results(:, 8) ;

	%Power Demand = Charging[3,7,8] - Injecting[5,6] 
	sim_Power = sim_results(:, 3) + sim_results(:, 7) + sim_results(:, 8) - sim_results(:, 5) - sim_results(:, 6);


	results_DTD(x, 1) = sim_DTD(x, 1);
	% results_DTD2(x, 1) = 0;
	% results_DTD3(x, 1) = 0;

	% if (DSR_duration == 2)

	% 	if (x < 24)
	% 		results_DTD2(x, 1) = sim_results(x+1, 5);
	% 	elseif (x==1)
	% 		results_DTD2(24, 1) = sim_results(x+1, 5);
	% 	else
	% 		results_DTD2(x, 1) = NaN;
	% 	end

	% elseif (DSR_duration == 3)
	% 	if (x<=23)
	% 		results_DTD2(x, 1) = sim_results(x+1, 5);
	% 	else
	% 		results_DTD2(x, 1) = NaN;
	% 	end

	% 	if (x<=22)
	% 		results_DTD3(x, 1) = sim_results(x+2, 5);
	% 	else
	% 		results_DTD3(x, 1) = NaN;
	% 	end
	% end

	%make results square
	for y = 1:24
		results_hours2(2*y -1, 1) = y-1;
		results_hours2(2*y, 1) =  y-0.001;

		sim_vehicles_home2(2*y -1, 1) = sim_vehicles_home(y, 1);
		sim_vehicles_home2(2*y, 1) = sim_vehicles_home(y, 1);		

		sim_charging2(2*y -1, 1) = sim_charging(y, 1);
		sim_charging2(2*y, 1) = sim_charging(y, 1);

		sim_not_charging2(2*y -1, 1) = sim_not_charging(y, 1);
		sim_not_charging2(2*y, 1) = sim_not_charging(y, 1);		

		sim_DTU2(2*y -1, 1) = sim_DTU(y, 1);
		sim_DTU2(2*y, 1) = sim_DTU(y, 1);

		sim_DTD2(2*y -1, 1) = sim_DTD(y, 1);
		sim_DTD2(2*y, 1) = sim_DTD(y, 1);

		sim_Power2(2*y -1, 1) = sim_Power(y, 1);
		sim_Power2(2*y, 1) = sim_Power(y, 1);
	end

  	% %Plot Square Results From Individual Simulation
		% var1 = sim_vehicles_home*ChargeRate/1000;
		% var2 = sim_charging2*ChargeRate/1000;
		% var3 = sim_not_charging2*ChargeRate/1000;
		% var4 = sim_DTU2*ChargeRate/1000;
		% var5 = sim_DTD2*ChargeRate/1000;

		% svar1 = 'Vehicles Home';
		% svar2 = 'Vehicles Charging';
		% svar3 = 'Vehicles Not Charging';
		% svar4 = 'Demand Turn Up';
		% svar5 = 'Demand Turn Down';

		% figure
		% plot(results_hours, (var1),results_hours2, (var2), results_hours2, (var3), results_hours2, (var4), results_hours2, (var5)) 
		% legend(svar1, svar2, svar3, svar4, svar5)
		% s_title = '{\bf\fontsize{14} Power usage of Vehicle Fleet under Demand Response Activation}';
		% s_subTitle = 'DSR Service: Demand Turn Down, Time:' + string(DSR_hour) + ':00 - ' + string(DSR_hour+DSR_duration) + ':00' ;
		% title( {s_title;s_subTitle},'FontWeight','Normal' )
		% xlabel('Time of Day (hr)') 
		% ylabel('Power (MW)') 
		% if save_img
		% 	print('V2G_Turn_Down_' + string(x) ,'-dpng')
		% end
		% close


		% Create area Plot for Power Only 
		var1 = sim_vehicles_home/fleet_Size * 100;
		var2 = sim_Power2*ChargeRate/1000;
		var3 = sim_charging2*ChargeRate/1000;
		var4 = sim_not_charging2*ChargeRate/1000;
		var5 = sim_DTD2*ChargeRate/1000;
		Power_Demand_Turn_Down(:, x) = var2;

		svar1 = 'Vehicles Home';
		svar2 = 'Power Demand';
		svar3 = 'Available Turn Up';
		svar4 = 'Available Turn Down';
		svar5 = 'Demand Turn Down';

		figure
		yyaxis right
		p = plot(results_hours, (var1));
		p(1).LineWidth = 2;
		ylabel('Percentage of Fleet Plugged In') 
		axis([0 24 -100 100])
		hold on

		yyaxis left
		q = plot(results_hours2, (var2), results_hours2, (var3), results_hours2, (var4), results_hours2, (var5)) ;
		q(1).LineWidth = 2;
		axis([0 24 -ChargeRate*fleet_Size/1000 ChargeRate*fleet_Size/1000])
		% area(results_hours2,sim_DTD2*ChargeRate/1000,'DisplayName','plot_data4','LineWidth',0.1);
		legend(svar2, svar3, svar4, svar5)
		s_title = '{\bf\fontsize{14} Power usage of Vehicle Fleet under Demand Response Activation}';
		s_subTitle = 'DSR Service: Demand Turn Down, Time:' + string(DSR_hour) + ':00 - ' + string(DSR_hour+DSR_duration) + ':00' ;
		title( {s_title;s_subTitle},'FontWeight','Normal' )
		xlabel('Time of Day (hr)') 
		ylabel('Power (MW)') 
		if save_img
    		print('V2G_Turn_Down_' + string(x) ,'-dpng')
		end
		close

	% %Plot Non Square Results From Individual Simulation
	% 	figure
	% 	plot(results_hours, (sim_vehicles_home), results_hours, (sim_charging), results_hours, (sim_not_charging), results_hours, (sim_DTD), results_hours, (sim_DTU)) 
	% 	xlabel('Time of Day (hr)') 
	% 	ylabel('Number of Vehicles') 
	% 	legend('Vehicles at Home', 'Vehicles Charging', 'Vehicles Not Charging', 'Demand Turn Down', 'Demand Turn Up')

end


%% Run Simulation for Demand Turn Up every hour of the day
DSR_direction = 2;
for x = 1:24
	DSR_hour = x;
	DSR_details = [DSR_hour, DSR_direction, DSR_duration, ChargeRate, fleet_Size, StartSoC, Req_SoC, BatSize];
	sim_results = Charge_V2G(DSR_details);

	%sim_results = 24:8
	%sim_results(:, 1) = hour of day
	%sim_results(:, 2) = Vehicles at Home
	%sim_results(:, 3) = Vehicles Charging     - No DSR
	%sim_results(:, 4) = Vehicles Not Charging - No DSR
	%sim_results(:, 5) = Vehicles was Charging     - Now Injecting
	%sim_results(:, 6) = Vehicles was Not Charging - Now Injecting
	%sim_results(:, 7) = Vehicles was Charging     - Now Charging    --- This is a useless state but left in to keep symmetry
	%sim_results(:, 8) = Vehicles was Not Charging - Now Charging



	%Power Demand = Charging[3,7,8] - Injecting[5,6] 

	%% Save Results For Evaluation
	%Simulation Details
	sim_details(x, :) = DSR_details();

	%Simulation Results
	sim_vehicles_home(:, 1) = sim_results(:, 2);
	sim_charging(:, 1) = sim_results(:, 3);
	sim_not_charging(:, 1) = sim_results(:, 4);

	%Demand Turn Down = 2*(Charge -> Inject[5]) + 1*(Not-Charge -> Inject[6])
	%Demand Turn Up   = 0*(Charge -> Charge[7]) + 1*(Not-Charge -> Charge[8])
	sim_DTD(:, 1) = 2*sim_results(:, 5) + 1*sim_results(:, 6) ;
	sim_DTU(:, 1) = 0*sim_results(:, 7) + 1*sim_results(:, 8) ;

	%Power Demand = Charging[3,7,8] - Injecting[5,6] 
	sim_Power = sim_results(:, 3) + sim_results(:, 7) + sim_results(:, 8) - sim_results(:, 5) - sim_results(:, 6);

	results_DTU(x, 1) = sim_DTU(x, 1);
	% results_DTU2(x, 1) = 0;
	% results_DTU3(x, 1) = 0;

	% if (DSR_duration == 2)

	% 	if (x < 24)
	% 		results_DTU2(x, 1) = sim_results(x+1, 6);
	% 	elseif (x==1)
	% 		results_DTU2(24, 1) = sim_results(x+1, 6);
	% 	else
	% 		results_DTU2(x, 1) = NaN;
	% 	end

	% elseif (DSR_duration == 3)
	% 	if (x<=23)
	% 		results_DTU2(x, 1) = sim_results(x+1, 6);
	% 	else
	% 		results_DTU2(x, 1) = NaN;
	% 	end

	% 	if (x<=22)
	% 		results_DTU3(x, 1) = sim_results(x+2, 6);
	% 	else
	% 		results_DTU3(x, 1) = NaN;
	% 	end
	% end


	%make results square
	for y = 1:24
		results_hours2(2*y -1, 1) = y-1;
		results_hours2(2*y, 1) =  y-0.001;

		sim_vehicles_home2(2*y -1, 1) = sim_vehicles_home(y, 1);
		sim_vehicles_home2(2*y, 1) = sim_vehicles_home(y, 1);		

		sim_charging2(2*y -1, 1) = sim_charging(y, 1);
		sim_charging2(2*y, 1) = sim_charging(y, 1);

		sim_not_charging2(2*y -1, 1) = sim_not_charging(y, 1);
		sim_not_charging2(2*y, 1) = sim_not_charging(y, 1);		

		sim_DTU2(2*y -1, 1) = sim_DTU(y, 1);
		sim_DTU2(2*y, 1) = sim_DTU(y, 1);

		sim_DTD2(2*y -1, 1) = sim_DTD(y, 1);
		sim_DTD2(2*y, 1) = sim_DTD(y, 1);

		sim_Power2(2*y -1, 1) = sim_Power(y, 1);
		sim_Power2(2*y, 1) = sim_Power(y, 1);
	end

  	% %Plot Square Results From Individual Simulation
		% var1 = sim_vehicles_home*ChargeRate/1000;
		% var2 = sim_charging2*ChargeRate/1000;
		% var3 = sim_not_charging2*ChargeRate/1000;
		% var4 = sim_DTU2*ChargeRate/1000;
		% var5 = sim_DTD2*ChargeRate/1000;

		% svar1 = 'Vehicles Home';
		% svar2 = 'Vehicles Charging';
		% svar3 = 'Vehicles Not Charging';
		% svar4 = 'Demand Turn Up';
		% svar5 = 'Demand Turn Down';

		% figure
		% plot(results_hours, (var1),results_hours2, (var2), results_hours2, (var3), results_hours2, (var4), results_hours2, (var5)) 
		% legend(svar1, svar2, svar3, svar4, svar5)
		% s_title = '{\bf\fontsize{14} Power usage of Vehicle Fleet under Demand Response Activation}';
		% s_subTitle = 'DSR Service: Demand Turn Down, Time:' + string(DSR_hour) + ':00 - ' + string(DSR_hour+DSR_duration) + ':00' ;
		% title( {s_title;s_subTitle},'FontWeight','Normal' )
		% xlabel('Time of Day (hr)') 
		% ylabel('Power (MW)') 
		% if save_img
		% 	print('V2G_Turn_Down_' + string(x) ,'-dpng')
		% end
		% close


		% Create area Plot for Power Only 
		var1 = sim_vehicles_home/fleet_Size * 100;
		var2 = sim_Power2*ChargeRate/1000;
		var3 = sim_charging2*ChargeRate/1000;
		var4 = sim_not_charging2*ChargeRate/1000;
		var5 = sim_DTU2*ChargeRate/1000;

		svar1 = 'Vehicles Home';
		svar2 = 'Power Demand';
		svar3 = 'Available Turn Up';
		svar4 = 'Available Turn Down';
		svar5 = 'Demand Turn Up';

		figure
		yyaxis right
		p = plot(results_hours, (var1));
		p(1).LineWidth = 2;
		ylabel('Percentage of Fleet Plugged In') 
		axis([0 24 -100 100])
		hold on

		yyaxis left
		q = plot(results_hours2, (var2), results_hours2, (var3), results_hours2, (var4), results_hours2, (var5)) ;
		q(1).LineWidth = 2;
		axis([0 24 -ChargeRate*fleet_Size/1000 ChargeRate*fleet_Size/1000])
		% area(results_hours2,sim_DTD2*ChargeRate/1000,'DisplayName','plot_data4','LineWidth',0.1);
		legend(svar2, svar3, svar4, svar5)
		s_title = '{\bf\fontsize{14} Power usage of Vehicle Fleet under Demand Response Activation}';
		s_subTitle = 'DSR Service: Demand Turn Up, Time:' + string(DSR_hour) + ':00 - ' + string(DSR_hour+DSR_duration) + ':00' ;
		title( {s_title;s_subTitle},'FontWeight','Normal' )
		xlabel('Time of Day (hr)') 
		ylabel('Power (MW)') 
		if save_img
    		print('V2G_Turn_Up_' + string(x) ,'-dpng')
		end
		close

	% %Plot Non Square Results From Individual Simulation
	% 	figure
	% 	plot(results_hours, (sim_vehicles_home), results_hours, (sim_charging), results_hours, (sim_not_charging), results_hours, (sim_DTD), results_hours, (sim_DTU)) 
	% 	xlabel('Time of Day (hr)') 
	% 	ylabel('Number of Vehicles') 
	% 	legend('Vehicles at Home', 'Vehicles Charging', 'Vehicles Not Charging', 'Demand Turn Down', 'Demand Turn Up')

end


%% Run Simulation for No Service
DSR_direction = 0;
for x = 1:1
	DSR_hour = x;
	DSR_details = [DSR_hour, DSR_direction, DSR_duration, ChargeRate, fleet_Size, StartSoC, Req_SoC, BatSize];
	sim_results = Charge_V2G(DSR_details);

	%sim_results = 24:8
	%sim_results(:, 1) = hour of day
	%sim_results(:, 2) = Vehicles at Home
	%sim_results(:, 3) = Vehicles Charging     - No DSR
	%sim_results(:, 4) = Vehicles Not Charging - No DSR
	%sim_results(:, 5) = Vehicles was Charging     - Now Injecting
	%sim_results(:, 6) = Vehicles was Not Charging - Now Injecting
	%sim_results(:, 7) = Vehicles was Charging     - Now Charging    --- This is a useless state but left in to keep symmetry
	%sim_results(:, 8) = Vehicles was Not Charging - Now Charging



	%Power Demand = Charging[3,7,8] - Injecting[5,6] 

	%% Save Results For Evaluation
	%Simulation Details
	sim_details(x, :) = DSR_details();

	%Simulation Results
	sim_vehicles_home(:, 1) = sim_results(:, 2);
	sim_charging(:, 1) = sim_results(:, 3);
	sim_not_charging(:, 1) = sim_results(:, 4);

	%Demand Turn Down = 2*(Charge -> Inject[5]) + 1*(Not-Charge -> Inject[6])
	%Demand Turn Up   = 0*(Charge -> Charge[7]) + 1*(Not-Charge -> Charge[8])
	sim_DTD(:, 1) = 2*sim_results(:, 5) + 1*sim_results(:, 6) ;
	sim_DTU(:, 1) = 0*sim_results(:, 7) + 1*sim_results(:, 8) ;

	%Power Demand = Charging[3,7,8] - Injecting[5,6] 
	sim_Power = sim_results(:, 3) + sim_results(:, 7) + sim_results(:, 8) - sim_results(:, 5) - sim_results(:, 6);

	%make results square
	for y = 1:24
		results_hours2(2*y -1, 1) = y-1;
		results_hours2(2*y, 1) =  y-0.001;

		sim_vehicles_home2(2*y -1, 1) = sim_vehicles_home(y, 1);
		sim_vehicles_home2(2*y, 1) = sim_vehicles_home(y, 1);		

		sim_charging2(2*y -1, 1) = sim_charging(y, 1);
		sim_charging2(2*y, 1) = sim_charging(y, 1);

		sim_not_charging2(2*y -1, 1) = sim_not_charging(y, 1);
		sim_not_charging2(2*y, 1) = sim_not_charging(y, 1);		

		sim_DTU2(2*y -1, 1) = sim_DTU(y, 1);
		sim_DTU2(2*y, 1) = sim_DTU(y, 1);

		sim_DTD2(2*y -1, 1) = sim_DTD(y, 1);
		sim_DTD2(2*y, 1) = sim_DTD(y, 1);

		sim_Power2(2*y -1, 1) = sim_Power(y, 1);
		sim_Power2(2*y, 1) = sim_Power(y, 1);
	end

  	% %Plot Square Results From Individual Simulation
		% var1 = sim_vehicles_home*ChargeRate/1000;
		% var2 = sim_charging2*ChargeRate/1000;
		% var3 = sim_not_charging2*ChargeRate/1000;
		% var4 = sim_DTU2*ChargeRate/1000;
		% var5 = sim_DTD2*ChargeRate/1000;

		% svar1 = 'Vehicles Home';
		% svar2 = 'Vehicles Charging';
		% svar3 = 'Vehicles Not Charging';
		% svar4 = 'Demand Turn Up';
		% svar5 = 'Demand Turn Down';

		% figure
		% plot(results_hours, (var1),results_hours2, (var2), results_hours2, (var3), results_hours2, (var4), results_hours2, (var5)) 
		% legend(svar1, svar2, svar3, svar4, svar5)
		% s_title = '{\bf\fontsize{14} Power usage of Vehicle Fleet under Demand Response Activation}';
		% s_subTitle = 'DSR Service: Demand Turn Down, Time:' + string(DSR_hour) + ':00 - ' + string(DSR_hour+DSR_duration) + ':00' ;
		% title( {s_title;s_subTitle},'FontWeight','Normal' )
		% xlabel('Time of Day (hr)') 
		% ylabel('Power (MW)') 
		% if save_img
		% 	print('V2G_Turn_Down_' + string(x) ,'-dpng')
		% end
		% close


		% Create area Plot for Power Only 
		var1 = sim_vehicles_home/fleet_Size * 100;
		var2 = sim_Power2*ChargeRate/1000;
		var3 = sim_charging2*ChargeRate/1000;
		var4 = sim_not_charging2*ChargeRate/1000;
		var5 = sim_DTU2*ChargeRate/1000;

		svar1 = 'Vehicles Home';
		svar2 = 'Power Demand';
		svar3 = 'Available Turn Up';
		svar4 = 'Available Turn Down';
		svar5 = 'Demand Turn Up';

		figure
		yyaxis right
		p = plot(results_hours, (var1));
		p(1).LineWidth = 2;
		ylabel('Percentage of Fleet Plugged In') 
		axis([0 24 -100 100])
		hold on

		yyaxis left
		q = plot(results_hours2, (var2), results_hours2, (var3), results_hours2, (var4), results_hours2, (var5)) ;
		q(1).LineWidth = 2;
		axis([0 24 -ChargeRate*fleet_Size/1000 ChargeRate*fleet_Size/1000])
		% area(results_hours2,sim_DTD2*ChargeRate/1000,'DisplayName','plot_data4','LineWidth',0.1);
		legend(svar2, svar3, svar4, svar5)
		s_title = '{\bf\fontsize{14} Power usage of Vehicle Fleet under Demand Response Activation}';
		s_subTitle = 'DSR Service: No Service' ;
		title( {s_title;s_subTitle},'FontWeight','Normal' )
		xlabel('Time of Day (hr)') 
		ylabel('Power (MW)') 
		if save_img
    		print('V2G_No_Service' ,'-dpng')
		end
		close

	% %Plot Non Square Results From Individual Simulation
	% 	figure
	% 	plot(results_hours, (sim_vehicles_home), results_hours, (sim_charging), results_hours, (sim_not_charging), results_hours, (sim_DTD), results_hours, (sim_DTU)) 
	% 	xlabel('Time of Day (hr)') 
	% 	ylabel('Number of Vehicles') 
	% 	legend('Vehicles at Home', 'Vehicles Charging', 'Vehicles Not Charging', 'Demand Turn Down', 'Demand Turn Up')

end

% Plot Results From All Simulations
%Plot DTU and DTD Achieved for hour of day
figure
plot(results_hours, results_DTD*ChargeRate/1000, results_hours, results_DTU*ChargeRate/1000) 
s_title = '{\bf\fontsize{14} DSR Power vs Time of Day}';
s_subTitle =  'Vehicle Fleet of ' + string(fleet_Size) + '  ' + string(ChargeRate) + 'kW Bi-Directional EVs' ;
title( {s_title;s_subTitle},'FontWeight','Normal')
axis([0 24 0 max(results_DTU*ChargeRate/1000)*1.1])
xlabel('Time of Day (hr)') 
ylabel('Power (MW)') 
legend('Demand Turn Down', 'Demand Turn Up')		
if save_img
	print('V2G Results' ,'-dpng')
end
close


%% Energy Balance

%Calculate total energy required for vehicle charging
Energy_Total = fleet_Size * (Req_SoC - StartSoC)*BatSize; %kWh
for temp = 1:24
	%Energy for Demand Turn Down = integral of power (remove square wave by only taking every second value)
% 	Energy_DTD(x,1) = sum(Power_Demand_Turn_Down(:, 2*x));
end



% %Plot DTU and DTD Achieved for hour of day with 2 hour DSR service
% if (DSR_duration == 2)
% 	figure
% 	q = plot(results_hours, results_DTD*ChargeRate/1000, 	results_hours, results_DTD2*ChargeRate/1000, 	results_hours, results_DTU*ChargeRate/1000, 	results_hours, results_DTU2*ChargeRate/1000) ;
% 	q(2).LineWidth = 2;
% 	q(4).LineWidth = 2;
% 	s_title = '{\bf\fontsize{14} DSR Power vs Time of Day}';
% 	s_subTitle =  'Vehicle Fleet of ' + string(fleet_Size) + '  ' + string(ChargeRate) + 'kW EVs' ;
% 	title( {s_title;s_subTitle},'FontWeight','Normal')
% 	axis([0 24 0 15])
% 	xlabel('Time of Day (hr)') 
% 	ylabel('Power (MW)') 
% 	legend('Demand Turn Down Hour 1', 'Demand Turn Down Hour 2', 'Demand Turn Up Hour 1', 'Demand Turn Up Hour 2')		
% 	if save_img
% 		print('V2G Results Hour 2' ,'-dpng')
% 	end
% 	close
% end

% % %Plot DTU and DTD Achieved for hour of day with 2 hour DSR service
% % if (DSR_duration == 2)
% % 	figure
% % 	plot(results_hours, results_DTU*ChargeRate/1000, 	results_hours, results_DTU2*ChargeRate/1000) 
% % 	s_title = '{\bf\fontsize{14} DSR Power vs Time of Day}';
% % 	s_subTitle =  'Vehicle Fleet of ' + string(fleet_Size) + '  ' + string(ChargeRate) + 'kW EVs' ;
% % 	title( {s_title;s_subTitle},'FontWeight','Normal')
% % 	axis([0 24 0 15])
% % 	xlabel('Time of Day (hr)') 
% % 	ylabel('Power (MW)') 
% % 	legend('Demand Turn Up Hour 1', 'Demand Turn Up Hour 2')		
% % 	if save_img
% % 		print('V2G Results Hour 2' ,'-dpng')
% % 	end
% % 	close
% % end

% %Plot DTU and DTD Achieved for hour of day with 3 hour DSR service
% if (DSR_duration == 3)
% 	figure
% 	q = plot(results_hours, results_DTD*ChargeRate/1000, 	results_hours, results_DTD2*ChargeRate/1000, 	results_hours, results_DTD3*ChargeRate/1000, 	results_hours, results_DTU*ChargeRate/1000, 	results_hours, results_DTU2*ChargeRate/1000, 	results_hours, results_DTU3*ChargeRate/1000) ;
% 	q(3).LineWidth = 2;
% 	q(6).LineWidth = 2;
% 	s_title = '{\bf\fontsize{14} DSR Power vs Time of Day}';
% 	s_subTitle =  'Vehicle Fleet of ' + string(fleet_Size) + '  ' + string(ChargeRate) + 'kW EVs' ;
% 	title( {s_title;s_subTitle},'FontWeight','Normal')
% 	axis([0 24 0 15])
% 	xlabel('Time of Day (hr)') 
% 	ylabel('Power (MW)') 
% 	legend('Demand Turn Down Hour 1', 'Demand Turn Down Hour 2', 'Demand Turn Down Hour 3', 'Demand Turn Up Hour 1', 'Demand Turn Up Hour 2', 'Demand Turn Up Hour 3')		
% 	if save_img
% 		print('V2G Results Hour 3' ,'-dpng')
% 	end
% 	close
% end

toc;

