%%     	Title: EV Scheduling Model
%  		Author: McDonald, Michael
%		Institution: University of Edinburgh, School of Engineering
%		Package: Matlab 2018b, Academic License
%    	Availability: https://github.com/mcdzim/EV_Scheduling_model/
%		License: Open
%    	Code version: 1.01
%    	Date: 16/04/2018
% 
% 		Permission is hereby granted, free of charge, to any person obtaining a copy
% 		of this software and associated documentation files (the "Software"), to deal
% 		in the Software without restriction, including without limitation the rights
% 		to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% 		copies of the Software, and to permit persons to whom the Software is
% 		furnished to do so, subject to the following conditions:

% 		The above copyright notice and this permission notice shall be included in
% 		all copies or substantial portions of the Software.

% 		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% 		IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% 		FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% 		AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% 		LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% 		OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% 		THE SOFTWARE.

%% ---------------------------------------------------------------------------------------
% 	Function Definitions
%---------------------------------------------------------------------------------------


%This script houses the entire collection of functions used in my research
%The algorithm was designed and run in Matlab

% DSR_Analyse
%		run through 24 hour period of DSR services with unidirectional chargers  

% V2G_Analyse
%		run through 24 hour period of DSR services with V2G bi-directional chargers 


%% ---------------------------------------------------------------------------------------
%	Functions
%---------------------------------------------------------------------------------------
function void = main(void)
	clear;
	tic; % Start Timer

	%Simulation Details
	DSR_duration = 1;
	fleet_Size = 5000;
	ChargeRate = 3;
	StartSoC = 0.5; 
	Req_SoC = 0.89;
	BatSize = 40;
	results_hours = linspace(0,23,24);
	save_img = 1;
	sim_details = [DSR_duration, fleet_Size, ChargeRate, BatSize, StartSoC, Req_SoC, save_img];


	% Run Uni-directional Analysis
		Uni_Directional = DSR_Analyse(sim_details);
		'DSR Complete'
		toc;



	% Run Bi-directional Analysis
		V2G_Analyse;
		'V2G Complete'
		toc;

	% %Run Sensitivity Analysis
	% 	Sensitivity_Analysis;
	% 	'Sensitivity Analysis'
	% 	toc;
end

%% ---------------------------------------------------------------------------------------
% 	DSR Charging with uni-diectional chargers
%---------------------------------------------------------------------------------------
function result = DSR_Charge(DSR_specs)
	%%Function Details
	% DSR_hour is the hour the service is called upon
	% DSR_direction is the service required: 0= no service, 1= turn down, 2=turn up
	% DSR_duration is the time service is needed for

	%Result is in the format of 24:8 with vehicles states for hours of day
	%Result(:, 1) = Hour of Day
	%Result(:, 2) = Number of Vehicles: At Home
	%Result(:, 3) = Number of Vehicles: Charging
	%Result(:, 4) = Number of Vehicles: Not Charging
	%Result(:, 5) = Number of Vehicles: Were Charging, Now Demand Turn Down
	%Result(:, 6) = Number of Vehicles: Were Not Charging, Now Demand Turn Down 	- N/A
	%Result(:, 7) = Number of Vehicles: Were Charging, Now Demand Turn Up 		    - N/A
	%Result(:, 8) = Number of Vehicles: Were Not Charging, Now Demand Turn Up
	%---------------------------------------------------------------------------------------

	DSR_hour = DSR_specs(1,1);
	DSR_direction = DSR_specs(1,2);
	DSR_duration = DSR_specs(1,3);
	save_img = 1;

	%% Fleet Definitions
	for n = 1
	  %fleet def = [fleet_Size, StartSoC, Req_SoC, BatSize, ChargeRate]
	  fleet_def = [DSR_specs(1,5), DSR_specs(1,6), DSR_specs(1,7), DSR_specs(1,8), DSR_specs(1,4)];
	  fleet_Size = fleet_def(1, 1);
	  StartSoC = fleet_def(1, 2);
	  Req_SoC = fleet_def(1, 3);
	  BatSize = fleet_def(1, 4);
	  ChargeRate = fleet_def(1, 5);
	  DSR_duration = DSR_duration - 0.01;

	  % Produce arrival and departue times using normal data
	  rng('default') % For reproducibility
	  %Arrival Times
	  fleet_data(1, 1:fleet_Size) = normrnd(19.16,3.62,[fleet_Size, 1]);
	  %Departure Time
	  fleet_data(2, 1:fleet_Size) = normrnd(10.53,3.26,[fleet_Size, 1]);
	  %Start SoC  
	  fleet_data(3, 1:fleet_Size) = StartSoC; 
	  %Required SoC
	  fleet_data(4, 1:fleet_Size) = Req_SoC; 
	    %Set required SoC to be one hour charge higher than for ASAP
	        %Removing for now as ruins energy calculations
	        %fleet_data(4, fleet_Size/2:fleet_Size) = Req_SoC + ChargeRate/BatSize;
	  %Current SoC
	  fleet_data(5, 1:fleet_Size) = StartSoC;
	  %Current State
	  fleet_data(6, 1:fleet_Size) = 0;
	  %Priority
	  fleet_data(7, 1:fleet_Size) = 0;
	  %Battery Size (kWh)
	  fleet_data(8, 1:fleet_Size) = BatSize;
	  %Charge Rate (kW)
	  fleet_data(9, 1:fleet_Size) = ChargeRate;
	  %Other


	   %As day is continuous need to move times greater than 24 to next morning
	  for x = 1 : length(fleet_data)
	      if  (fleet_data(1,x) >= 24)
	        fleet_data(1,x) = fleet_data(1,x) - 24 ;
	      end
	      if  (fleet_data(2,x) >= 24)
	        fleet_data(2,x) = fleet_data(2,x) - 24 ;
	        end
	  end 

	  % % Plot Histogram of arrivals and departures to make sure all times are <24h
	  % figure;
	  % yyaxis right
	  % histogram(fleet_data(1,:),'BinWidth',0.5)
	  % hold on
	  % histogram(fleet_data(2,:),'BinWidth',0.5)
	  % hold off
	  % hold on
	  % yyaxis left
	  % fleet_ASAP = Charge_MidP(fleet_data);
	  % plot(fleet_ASAP(1:24, 1), fleet_ASAP(1:24, 6))
	  % hold off
	  % legend('Vehicles at Home', 'Arrival', 'Departure')
	  % title('Arrival and Departure distribution of fleet')
	  % xlabel('Hour of Day') 
	  % ylabel('Number of Vehicles') 
	  % % print('Arrival and Departure Times','-dpng')
	  % % close
	end

	%% Setup Simulation Variables
	  FleetCharging(24, fleet_Size) = 0;
	  FleetChargingDSR(24, fleet_Size) = 0;   
	%% Calculate 1/2 of fleet using ASAP Priority
	for vehicle_num = 1 : length(fleet_data)/2
	    %extract variables for vehicle
	    current_vehicle(1:9, 1) = fleet_data(1:9, vehicle_num);
	    t_arr =  current_vehicle(1, 1);
	    t_dep = current_vehicle(2, 1);
	    start_SoC = current_vehicle(3, 1);
	    req_SoC = current_vehicle(4, 1);
	    curr_SoC = current_vehicle(5, 1);
	    bev_state = current_vehicle(6, 1);
	    batt_size = current_vehicle(8, 1);
	    charge_rate = current_vehicle(9, 1);

	    hour_start = ceil(t_arr);
	    t_dep_hour(vehicle_num) = ceil(t_dep);
	    
	        for hour_t = hour_start : 24
	          hour = hour_t;
	            %Check vehicle is at home
	            for temp_half_hour = 1:1
	                   time = hour;
	                   if ((t_arr <= time)  &&  (time <= t_dep))
	                       %if( home ) then state = -1
	                       current_vehicle(6,1) = -1; 
	                   elseif(  (t_dep < t_arr) && (time > t_arr)  )
	                       current_vehicle(6,1) = -1; 
	                   elseif(  (t_dep < t_arr) && (time < t_dep)  )
	                       current_vehicle(6,1) = -1; 
	                   else %else give state = 0
	                        current_vehicle(6,1) = 0; 
	                      %give current SoC = NaN
	                      current_vehicle(5, 1) = NaN;
	                        curr_SoC = NaN;
	                   end
	                   bev_state = current_vehicle(6, 1);
	            end

	            %Calculate time plugged in
	            for temp_half_hour = 1:1
	                t_plugged_in = hour-t_arr;
	                if (t_plugged_in<0)
	                    t_plugged_in = t_plugged_in + 24;
	                end
	            end

	            %Calculate time remaining plugged in
	            for temp_half_hour = 1:1
	                if ((t_dep< t_arr) && (t_dep < hour))
	                 t_rem = t_dep-hour + 24;           
	                else
	                 t_rem = t_dep-hour;                    
	                end
	            end

	            %Calculate Laxity
	            for temp_half_hour = 1:1
	              curr_SoC = current_vehicle(5, 1);
	                t_charge = (req_SoC-curr_SoC)*batt_size/charge_rate;
	                t_laxity =  t_rem - t_charge ;
	                %if laxity is negative set to 0
	                if (t_laxity < 0)

	                    t_laxity = 0;
	                end
	            end

	            %Set Priority of Vehicle
	            for temp_half_hour = 1:1
	                if (bev_state == 0)                         %If not plugged in
	                    %Set Priority to 0
	                    priority = 0;  
	                    %Set Laxity to Max
	                    t_laxity = 24;

	                elseif(req_SoC >= curr_SoC+charge_rate/batt_size)       %Charge Vehicle
	                    %Set Priority to 100
	                    priority = 100;   
	                    

	                elseif(curr_SoC <= 1- charge_rate/batt_size)        % If Not fully Charged and available for DTU  
	                    %Set Priority to 0
	                    priority = 10;  
	                    %Set Laxity to Max
	                    t_laxity = 24;   
	                else                          % If Fully Charged and not available for DTU  
	                    %Set Priority to 0
	                    priority = 0;  
	                    %Set Laxity to Max
	                    t_laxity = 24;   
	                       
	                end
	            end

	            %Charge Vehicles
	            for temp_half_hour = 1:1
	               cutoff_priority = 80;
	               current_vehicle(5, 1) = curr_SoC;
	               if ((DSR_hour <= hour) && (DSR_hour + DSR_duration >= hour)) % If within the DSR window
	                  if (DSR_direction == 0) %No DSR Service Called
	                      if (bev_state == 0) % Not Plugged In
	                          %State = Not Plugged in
	                          current_vehicle(6, 1) = 0;
	 
	                      elseif (priority < 10) %Do not Charge
	                          %State = Not Charging
	                          current_vehicle(6, 1) = 2;
	                          %Current SoC = Current SoC
	                          current_vehicle(5, 1) = current_vehicle(5, 1) + 0;

	                      elseif (priority >= cutoff_priority) %Above cutoff : Charge
	                          %State = Charging
	                          current_vehicle(6, 1) = 1;
	                          %Current SoC = Current SoC + hour of charge
	                          current_vehicle(5, 1) = current_vehicle(5, 1) + charge_rate/batt_size;

	                      else
	                          % Below cutoff for charge
	                          %State = Plugged in Not Charging
	                          current_vehicle(6, 1) = 2;
	                          %Current SoC = Current SoC;
	                          current_vehicle(5, 1) = current_vehicle(5, 1) + 0;
	                      end
	                
	                  elseif (DSR_direction == 1) % Demand Turn Down - stop charging
	                      if (bev_state == 0) % Not Plugged In
	                          %State = Not Plugged in
	                          current_vehicle(6, 1) = 0;

	                      elseif (priority <= 0) %Too full to charge 
	                          %State = Not Charging
	                          current_vehicle(6, 1) = 2;
	                          %Current SoC = Current SoC 
	                          current_vehicle(5, 1) = current_vehicle(5, 1) + 0 ;

	                      elseif (priority >= cutoff_priority) %Above cutoff, Should Charge : Now Not charging 
	                            %State = Was Charging, Now Not
	                            current_vehicle(6, 1) = 3;
	                            %Current SoC = Current SoC 
	                            current_vehicle(5, 1) = current_vehicle(5, 1) + 0;

	                      else % Below cutoff for charge
	                            %State = Was Not Charging, No change
	                            current_vehicle(6, 1) = 2;
	                            %Current SoC = Current SoC 
	                            current_vehicle(5, 1) = current_vehicle(5, 1) + 0;
	                      end

	                  elseif (DSR_direction == 2) % Demand Turn Up - start charging those waiting
	                      if (bev_state == 0) % Not Plugged In
	                          %State = Not Plugged in
	                          current_vehicle(6, 1) = 0;

	                      elseif (priority < 10) %Do not Charge - full battery
	                          %State = Not Charging
	                          current_vehicle(6, 1) = 2;
	                          %Current SoC = Current SoC
	                          current_vehicle(5, 1) = current_vehicle(5, 1) + 0;

	                      elseif (priority >= cutoff_priority) %Above cutoff : Charge like normal
	                          %State = Charging
	                          current_vehicle(6, 1) = 1;
	                          %Current SoC = Current SoC + hour of charge
	                          current_vehicle(5, 1) = current_vehicle(5, 1) + charge_rate/batt_size;

	                      else % Below cutoff for charge : Normally do not charge, now demand turn up
	                          %State = Demand turn Up
	                          current_vehicle(6, 1) = 6;
	                          %Current SoC = Current SoC + hour of charge
	                          current_vehicle(5, 1) = current_vehicle(5, 1) + charge_rate/batt_size;
	                      end
	          
	                  end

	               else %Act as if normal because outside DSR window
	                    if (bev_state == 0) % Not Plugged In
	                        %State = Not Plugged in
	                        current_vehicle(6, 1) = 0;

	                    elseif (priority <= 0) %Do not Charge
	                        %State = Not Charging
	                        current_vehicle(6, 1) = 2;
	                        %Current SoC = Current SoC
	                        current_vehicle(5, 1) = current_vehicle(5, 1) + 0;

	                    elseif (priority >= cutoff_priority) %Above cutoff : Charge
	                        %State = Charging
	                        current_vehicle(6, 1) = 1;
	                        %Current SoC = Current SoC + hour of charge
	                        current_vehicle(5, 1) = current_vehicle(5, 1) + charge_rate/batt_size;

	                    else % Below cutoff for charge
	                        %State = Plugged in Not Charging
	                        current_vehicle(6, 1) = 2;
	                        %Current SoC = Current SoC;
	                        current_vehicle(5, 1) = current_vehicle(5, 1) + 0;
	                    end
	               end   
	            end  

	            % Remove results showing 0 SoC when EV disconnected  
	            if(current_vehicle(5, 1) == 0)
	              current_vehicle(5,1) = NaN;
	            end

	            % Record Vehicle Status
	            fleet_data(1:9, vehicle_num) = current_vehicle(1:9, 1);
	            FleetCharging(hour, vehicle_num) = fleet_data(6, vehicle_num);
	            fleet_SoC(hour, vehicle_num) = fleet_data(5, vehicle_num);
	            fleet_Priority(hour, vehicle_num) = priority;
	        end
	  

	       for hour_t = 1 : hour_start-1
	          hour = hour_t;
	            %Check vehicle is at home
	            for temp_half_hour = 1:1
	                   time = hour;
	                   if ((t_arr <= time)  &&  (time <= t_dep))
	                       %if( home ) then state = -1
	                       current_vehicle(6,1) = -1; 
	                   elseif(  (t_dep < t_arr) && (time > t_arr)  )
	                       current_vehicle(6,1) = -1; 
	                   elseif(  (t_dep < t_arr) && (time < t_dep)  )
	                       current_vehicle(6,1) = -1; 
	                   else %else give state = 0
	                        current_vehicle(6,1) = 0; 
	                      %give current SoC = NaN
	                      current_vehicle(5, 1) = NaN;
	                        curr_SoC = NaN;
	                   end
	                   bev_state = current_vehicle(6, 1);
	            end

	            %Calculate time plugged in
	            for temp_half_hour = 1:1
	                t_plugged_in = hour-t_arr;
	                if (t_plugged_in<0)
	                    t_plugged_in = t_plugged_in + 24;
	                end
	            end

	            %Calculate time remaining plugged in
	            for temp_half_hour = 1:1
	                if ((t_dep< t_arr) && (t_dep < hour))
	                 t_rem = t_dep-hour + 24;           
	                else
	                 t_rem = t_dep-hour;                    
	                end
	            end

	            %Calculate Laxity
	            for temp_half_hour = 1:1
	              curr_SoC = current_vehicle(5, 1);
	                t_charge = (req_SoC-curr_SoC)*batt_size/charge_rate;
	                t_laxity =  t_rem - t_charge ;
	                %if laxity is negative set to 0
	                if (t_laxity < 0)

	                    t_laxity = 0;
	                end
	            end

	            %Set Priority of Vehicle
	            for temp_half_hour = 1:1
	                if (bev_state == 0)                         %If not plugged in
	                    %Set Priority to 0
	                    priority = 0;  
	                    %Set Laxity to Max
	                    t_laxity = 24;

	                elseif(req_SoC >= curr_SoC+charge_rate/batt_size)       %Charge Vehicle
	                    %Set Priority to 100
	                    priority = 100;   
	                    

	                elseif(curr_SoC <= 1- charge_rate/batt_size)        % If Not fully Charged and available for DTU  
	                    %Set Priority to 0
	                    priority = 10;  
	                    %Set Laxity to Max
	                    t_laxity = 24;   
	                else                          % If Fully Charged and not available for DTU  
	                    %Set Priority to 0
	                    priority = 0;  
	                    %Set Laxity to Max
	                    t_laxity = 24;   
	                       
	                end
	            end

	            %Charge Vehicles
	            for temp_half_hour = 1:1
	               cutoff_priority = 80;
	               current_vehicle(5, 1) = curr_SoC;
	               if ((DSR_hour <= hour) && (DSR_hour + DSR_duration >= hour)) % If within the DSR window
	                  if (DSR_direction == 0) %No DSR Service Called
	                      if (bev_state == 0) % Not Plugged In
	                          %State = Not Plugged in
	                          current_vehicle(6, 1) = 0;
	 
	                      elseif (priority < 10) %Do not Charge
	                          %State = Not Charging
	                          current_vehicle(6, 1) = 2;
	                          %Current SoC = Current SoC
	                          current_vehicle(5, 1) = current_vehicle(5, 1) + 0;

	                      elseif (priority >= cutoff_priority) %Above cutoff : Charge
	                          %State = Charging
	                          current_vehicle(6, 1) = 1;
	                          %Current SoC = Current SoC + hour of charge
	                          current_vehicle(5, 1) = current_vehicle(5, 1) + charge_rate/batt_size;

	                      else
	                          % Below cutoff for charge
	                          %State = Plugged in Not Charging
	                          current_vehicle(6, 1) = 2;
	                          %Current SoC = Current SoC;
	                          current_vehicle(5, 1) = current_vehicle(5, 1) + 0;
	                      end
	                
	                  elseif (DSR_direction == 1) % Demand Turn Down - stop charging
	                      if (bev_state == 0) % Not Plugged In
	                          %State = Not Plugged in
	                          current_vehicle(6, 1) = 0;

	                      elseif (priority <= 0) %Too full to charge 
	                          %State = Not Charging
	                          current_vehicle(6, 1) = 2;
	                          %Current SoC = Current SoC 
	                          current_vehicle(5, 1) = current_vehicle(5, 1) + 0 ;

	                      elseif (priority >= cutoff_priority) %Above cutoff, Should Charge : Now Not charging 
	                            %State = Was Charging, Now Not
	                            current_vehicle(6, 1) = 3;
	                            %Current SoC = Current SoC 
	                            current_vehicle(5, 1) = current_vehicle(5, 1) + 0;

	                      else % Below cutoff for charge
	                            %State = Was Not Charging, No change
	                            current_vehicle(6, 1) = 2;
	                            %Current SoC = Current SoC 
	                            current_vehicle(5, 1) = current_vehicle(5, 1) + 0;
	                      end

	                  elseif (DSR_direction == 2) % Demand Turn Up - start charging those waiting
	                      if (bev_state == 0) % Not Plugged In
	                          %State = Not Plugged in
	                          current_vehicle(6, 1) = 0;

	                      elseif (priority < 10) %Do not Charge - full battery
	                          %State = Not Charging
	                          current_vehicle(6, 1) = 2;
	                          %Current SoC = Current SoC
	                          current_vehicle(5, 1) = current_vehicle(5, 1) + 0;

	                      elseif (priority >= cutoff_priority) %Above cutoff : Charge like normal
	                          %State = Charging
	                          current_vehicle(6, 1) = 1;
	                          %Current SoC = Current SoC + hour of charge
	                          current_vehicle(5, 1) = current_vehicle(5, 1) + charge_rate/batt_size;

	                      else % Below cutoff for charge : Normally do not charge, now demand turn up
	                          %State = Demand turn Up
	                          current_vehicle(6, 1) = 6;
	                          %Current SoC = Current SoC + hour of charge
	                          current_vehicle(5, 1) = current_vehicle(5, 1) + charge_rate/batt_size;
	                      end
	          
	                  end

	               else %Act as if normal because outside DSR window
	                    if (bev_state == 0) % Not Plugged In
	                        %State = Not Plugged in
	                        current_vehicle(6, 1) = 0;

	                    elseif (priority <= 0) %Do not Charge
	                        %State = Not Charging
	                        current_vehicle(6, 1) = 2;
	                        %Current SoC = Current SoC
	                        current_vehicle(5, 1) = current_vehicle(5, 1) + 0;

	                    elseif (priority >= cutoff_priority) %Above cutoff : Charge
	                        %State = Charging
	                        current_vehicle(6, 1) = 1;
	                        %Current SoC = Current SoC + hour of charge
	                        current_vehicle(5, 1) = current_vehicle(5, 1) + charge_rate/batt_size;

	                    else % Below cutoff for charge
	                        %State = Plugged in Not Charging
	                        current_vehicle(6, 1) = 2;
	                        %Current SoC = Current SoC;
	                        current_vehicle(5, 1) = current_vehicle(5, 1) + 0;
	                    end
	               end   
	            end  

	            % Remove results showing 0 SoC when EV disconnected  
	            if(current_vehicle(5, 1) == 0)
	              current_vehicle(5,1) = NaN;
	            end

	            % Record Vehicle Status
	            fleet_data(1:9, vehicle_num) = current_vehicle(1:9, 1);
	            FleetCharging(hour, vehicle_num) = fleet_data(6, vehicle_num);
	            fleet_SoC(hour, vehicle_num) = fleet_data(5, vehicle_num);
	            fleet_Priority(hour, vehicle_num) = priority;
	        end
	end

	%% Calculate 1/2 of fleet using ALAP Priority
	for vehicle_num =  length(fleet_data)/2+1 :  length(fleet_data)
	    %extract variables for vehicle
	    current_vehicle(1:9, 1) = fleet_data(1:9, vehicle_num);
	    t_arr =  current_vehicle(1, 1);
	    t_dep = current_vehicle(2, 1);
	    start_SoC = current_vehicle(3, 1);
	    req_SoC = current_vehicle(4, 1);
	    curr_SoC = current_vehicle(5, 1);
	    bev_state = current_vehicle(6, 1);
	    batt_size = current_vehicle(8, 1);
	    charge_rate = current_vehicle(9, 1);

	    hour_start = ceil(t_arr);
	    t_dep_hour(vehicle_num) = ceil(t_dep);
	    laxity_cutoff = 0.1;
	    
	        for hour_t = hour_start : 24
	          hour = hour_t;
	            %Check vehicle is at home
	            for temp_half_hour = 1:1
	                   time = hour;
	                   if ((t_arr <= time)  &&  (time <= t_dep))
	                       %if( home ) then state = -1
	                       current_vehicle(6,1) = -1; 
	                   elseif(  (t_dep < t_arr) && (time > t_arr)  )
	                       current_vehicle(6,1) = -1; 
	                   elseif(  (t_dep < t_arr) && (time < t_dep)  )
	                       current_vehicle(6,1) = -1; 
	                   else %else give state = 0
	                        current_vehicle(6,1) = 0; 
	                      %give current SoC = 0
	                      current_vehicle(5, 1) = 0;
	                   end
	                   bev_state = current_vehicle(6, 1);
	            end

	            %Calculate time plugged in
	            for temp_half_hour = 1:1
	                t_plugged_in = hour-t_arr;
	                if (t_plugged_in<0)
	                    t_plugged_in = t_plugged_in + 24;
	                end
	            end

	            %Calculate time remaining plugged in
	            for temp_half_hour = 1:1
	                if ((t_dep< t_arr) && (t_dep < hour))
	                 t_rem = t_dep-hour + 24;           
	                else
	                 t_rem = t_dep-hour;                    
	                end
	            end

	            %Calculate Laxity
	            for temp_half_hour = 1:1
	              curr_SoC = current_vehicle(5, 1);
	                t_charge = (req_SoC-curr_SoC)*batt_size/charge_rate;
	                t_laxity =  t_rem - t_charge +1 ;
	                %if laxity is negative set to 0
	                if (t_laxity < 0)

	                    t_laxity = 0;
	                end
	            end

	            %Set Priority of Vehicle 
	            for temp_half_hour = 1:1
	              if (bev_state == 0)             %If not plugged in
	                %Set Priority to 0
	                priority = 0;  
	                %Set Laxity to Max
	                t_laxity = 24;
	                
	              elseif(t_laxity < laxity_cutoff)         %If Laxity less than 1 hour: Charge
	                %Set Priority to 100
	                priority = 100;  

	              elseif(curr_SoC <= 1-charge_rate/batt_size)  % Not Chraging but available for DTU  
	                    %Set Priority to 0
	                    priority = 10;  
	                    %Set Laxity to Max
	                    t_laxity = 24;   
	              else                            %Else Vehicle Fully Charged 
	                %Set Priority to 0
	                priority = 0;  
	              end
	            end

	            %Charge Vehicles
	            for temp_half_hour = 1:1
	               cutoff_priority = 80;
	               current_vehicle(5, 1) = curr_SoC;
	               if ((DSR_hour <= hour) && (DSR_hour + DSR_duration >= hour)) % If within the DSR window
	                  if (DSR_direction == 0) %No DSR Service Called
	                      if (bev_state == 0) % Not Plugged In
	                          %State = Not Plugged in
	                          current_vehicle(6, 1) = 0;
	 
	                      elseif (priority < 10) %Do not Charge
	                          %State = Not Charging
	                          current_vehicle(6, 1) = 2;
	                          %Current SoC = Current SoC
	                          current_vehicle(5, 1) = current_vehicle(5, 1) + 0;

	                      elseif (priority >= cutoff_priority) %Above cutoff : Charge
	                          %State = Charging
	                          current_vehicle(6, 1) = 1;
	                          %Current SoC = Current SoC + hour of charge
	                          current_vehicle(5, 1) = current_vehicle(5, 1) + charge_rate/batt_size;

	                      else
	                          % Below cutoff for charge
	                          %State = Plugged in Not Charging
	                          current_vehicle(6, 1) = 2;
	                          %Current SoC = Current SoC;
	                          current_vehicle(5, 1) = current_vehicle(5, 1) + 0;
	                      end
	                
	                  elseif (DSR_direction == 1) % Demand Turn Down - stop charging
	                      if (bev_state == 0) % Not Plugged In
	                          %State = Not Plugged in
	                          current_vehicle(6, 1) = 0;

	                      elseif (priority <= 0) %Too full to charge 
	                          %State = Not Charging
	                          current_vehicle(6, 1) = 2;
	                          %Current SoC = Current SoC 
	                          current_vehicle(5, 1) = current_vehicle(5, 1) + 0 ;

	                      elseif (priority >= cutoff_priority) %Above cutoff, Should Charge : Now Not charging 
	                            %State = Was Charging, Now Not
	                            current_vehicle(6, 1) = 3;
	                            %Current SoC = Current SoC 
	                            current_vehicle(5, 1) = current_vehicle(5, 1) + 0;

	                      else % Below cutoff for charge
	                            %State = Was Not Charging, No change
	                            current_vehicle(6, 1) = 2;
	                            %Current SoC = Current SoC 
	                            current_vehicle(5, 1) = current_vehicle(5, 1) + 0;
	                      end

	                  elseif (DSR_direction == 2) % Demand Turn Up - start charging those waiting
	                      if (bev_state == 0) % Not Plugged In
	                          %State = Not Plugged in
	                          current_vehicle(6, 1) = 0;

	                      elseif (priority < 10) %Do not Charge - full battery
	                          %State = Not Charging
	                          current_vehicle(6, 1) = 2;
	                          %Current SoC = Current SoC
	                          current_vehicle(5, 1) = current_vehicle(5, 1) + 0;

	                      elseif (priority >= cutoff_priority) %Above cutoff : Charge like normal
	                          %State = Charging
	                          current_vehicle(6, 1) = 1;
	                          %Current SoC = Current SoC + hour of charge
	                          current_vehicle(5, 1) = current_vehicle(5, 1) + charge_rate/batt_size;

	                      else % Below cutoff for charge : Normally do not charge, now demand turn up
	                          %State = Demand turn Up
	                          current_vehicle(6, 1) = 6;
	                          %Current SoC = Current SoC + hour of charge
	                          current_vehicle(5, 1) = current_vehicle(5, 1) + charge_rate/batt_size;
	                      end
	          
	                  end

	               else %Act as if normal because outside DSR window
	                    if (bev_state == 0) % Not Plugged In
	                        %State = Not Plugged in
	                        current_vehicle(6, 1) = 0;

	                    elseif (priority <= 0) %Do not Charge
	                        %State = Not Charging
	                        current_vehicle(6, 1) = 2;
	                        %Current SoC = Current SoC
	                        current_vehicle(5, 1) = current_vehicle(5, 1) + 0;

	                    elseif (priority >= cutoff_priority) %Above cutoff : Charge
	                        %State = Charging
	                        current_vehicle(6, 1) = 1;
	                        %Current SoC = Current SoC + hour of charge
	                        current_vehicle(5, 1) = current_vehicle(5, 1) + charge_rate/batt_size;

	                    else % Below cutoff for charge
	                        %State = Plugged in Not Charging
	                        current_vehicle(6, 1) = 2;
	                        %Current SoC = Current SoC;
	                        current_vehicle(5, 1) = current_vehicle(5, 1) + 0;
	                    end
	               end   
	            end  

	            % Remove results showing 0 SoC when EV disconnected  
	            if(current_vehicle(5, 1) == 0)
	              current_vehicle(5,1) = NaN;
	            end


	            % Record Vehicle Status
	            fleet_data(1:9, vehicle_num) = current_vehicle(1:9, 1);
	            FleetCharging(hour, vehicle_num) = fleet_data(6, vehicle_num);
	            fleet_SoC(hour, vehicle_num) = fleet_data(5, vehicle_num);
	            fleet_Priority(hour, vehicle_num) = priority;
	        end
	  

	       for hour_t = 1 : hour_start-1
	          hour = hour_t;
	            %Check vehicle is at home
	            for temp_half_hour = 1:1
	                   time = hour;
	                   if ((t_arr <= time)  &&  (time <= t_dep))
	                       %if( home ) then state = -1
	                       current_vehicle(6,1) = -1; 
	                   elseif(  (t_dep < t_arr) && (time > t_arr)  )
	                       current_vehicle(6,1) = -1; 
	                   elseif(  (t_dep < t_arr) && (time < t_dep)  )
	                       current_vehicle(6,1) = -1; 
	                   else %else give state = 0
	                        current_vehicle(6,1) = 0; 
	                      %give current SoC = 0
	                      current_vehicle(5, 1) = 0;
	                   end
	                   bev_state = current_vehicle(6, 1);
	            end

	            %Calculate time plugged in
	            for temp_half_hour = 1:1
	                t_plugged_in = hour-t_arr;
	                if (t_plugged_in<0)
	                    t_plugged_in = t_plugged_in + 24;
	                end
	            end

	            %Calculate time remaining plugged in
	            for temp_half_hour = 1:1
	                if ((t_dep< t_arr) && (t_dep < hour))
	                 t_rem = t_dep-hour + 24;           
	                else
	                 t_rem = t_dep-hour;                    
	                end
	            end

	            %Calculate Laxity
	            for temp_half_hour = 1:1
	              curr_SoC = current_vehicle(5, 1);
	                t_charge = (req_SoC-curr_SoC)*batt_size/charge_rate;
	                t_laxity =  t_rem - t_charge +1 ;
	                %if laxity is negative set to 0
	                if (t_laxity < 0)

	                    t_laxity = 0;
	                end
	            end

	            %Set Priority of Vehicle 
	            for temp_half_hour = 1:1
	              if (bev_state == 0)             %If not plugged in
	                %Set Priority to 0
	                priority = 0;  
	                %Set Laxity to Max
	                t_laxity = 24;
	                
	              elseif(t_laxity < laxity_cutoff)         %If Laxity less than 1 hour: Charge
	                %Set Priority to 100
	                priority = 100;  

	              elseif(curr_SoC <= 1-charge_rate/batt_size)  % Not Chraging but available for DTU  
	                    %Set Priority to 0
	                    priority = 10;  
	                    %Set Laxity to Max
	                    t_laxity = 24;   
	              else                            %Else Vehicle Fully Charged 
	                %Set Priority to 0
	                priority = 0;  
	              end
	            end

	            %Charge Vehicles
	            for temp_half_hour = 1:1
	               cutoff_priority = 80;
	               current_vehicle(5, 1) = curr_SoC;
	               if ((DSR_hour <= hour) && (DSR_hour + DSR_duration >= hour)) % If within the DSR window
	                  if (DSR_direction == 0) %No DSR Service Called
	                      if (bev_state == 0) % Not Plugged In
	                          %State = Not Plugged in
	                          current_vehicle(6, 1) = 0;
	 
	                      elseif (priority < 10) %Do not Charge
	                          %State = Not Charging
	                          current_vehicle(6, 1) = 2;
	                          %Current SoC = Current SoC
	                          current_vehicle(5, 1) = current_vehicle(5, 1) + 0;

	                      elseif (priority >= cutoff_priority) %Above cutoff : Charge
	                          %State = Charging
	                          current_vehicle(6, 1) = 1;
	                          %Current SoC = Current SoC + hour of charge
	                          current_vehicle(5, 1) = current_vehicle(5, 1) + charge_rate/batt_size;

	                      else
	                          % Below cutoff for charge
	                          %State = Plugged in Not Charging
	                          current_vehicle(6, 1) = 2;
	                          %Current SoC = Current SoC;
	                          current_vehicle(5, 1) = current_vehicle(5, 1) + 0;
	                      end
	                
	                  elseif (DSR_direction == 1) % Demand Turn Down - stop charging
	                      if (bev_state == 0) % Not Plugged In
	                          %State = Not Plugged in
	                          current_vehicle(6, 1) = 0;

	                      elseif (priority <= 0) %Too full to charge 
	                          %State = Not Charging
	                          current_vehicle(6, 1) = 2;
	                          %Current SoC = Current SoC 
	                          current_vehicle(5, 1) = current_vehicle(5, 1) + 0 ;

	                      elseif (priority >= cutoff_priority) %Above cutoff, Should Charge : Now Not charging 
	                            %State = Was Charging, Now Not
	                            current_vehicle(6, 1) = 3;
	                            %Current SoC = Current SoC 
	                            current_vehicle(5, 1) = current_vehicle(5, 1) + 0;

	                      else % Below cutoff for charge
	                            %State = Was Not Charging, No change
	                            current_vehicle(6, 1) = 2;
	                            %Current SoC = Current SoC 
	                            current_vehicle(5, 1) = current_vehicle(5, 1) + 0;
	                      end

	                  elseif (DSR_direction == 2) % Demand Turn Up - start charging those waiting
	                      if (bev_state == 0) % Not Plugged In
	                          %State = Not Plugged in
	                          current_vehicle(6, 1) = 0;

	                      elseif (priority < 10) %Do not Charge - full battery
	                          %State = Not Charging
	                          current_vehicle(6, 1) = 2;
	                          %Current SoC = Current SoC
	                          current_vehicle(5, 1) = current_vehicle(5, 1) + 0;

	                      elseif (priority >= cutoff_priority) %Above cutoff : Charge like normal
	                          %State = Charging
	                          current_vehicle(6, 1) = 1;
	                          %Current SoC = Current SoC + hour of charge
	                          current_vehicle(5, 1) = current_vehicle(5, 1) + charge_rate/batt_size;

	                      else % Below cutoff for charge : Normally do not charge, now demand turn up
	                          %State = Demand turn Up
	                          current_vehicle(6, 1) = 6;
	                          %Current SoC = Current SoC + hour of charge
	                          current_vehicle(5, 1) = current_vehicle(5, 1) + charge_rate/batt_size;
	                      end
	          
	                  end

	               else %Act as if normal because outside DSR window
	                    if (bev_state == 0) % Not Plugged In
	                        %State = Not Plugged in
	                        current_vehicle(6, 1) = 0;

	                    elseif (priority <= 0) %Do not Charge
	                        %State = Not Charging
	                        current_vehicle(6, 1) = 2;
	                        %Current SoC = Current SoC
	                        current_vehicle(5, 1) = current_vehicle(5, 1) + 0;

	                    elseif (priority >= cutoff_priority) %Above cutoff : Charge
	                        %State = Charging
	                        current_vehicle(6, 1) = 1;
	                        %Current SoC = Current SoC + hour of charge
	                        current_vehicle(5, 1) = current_vehicle(5, 1) + charge_rate/batt_size;

	                    else % Below cutoff for charge
	                        %State = Plugged in Not Charging
	                        current_vehicle(6, 1) = 2;
	                        %Current SoC = Current SoC;
	                        current_vehicle(5, 1) = current_vehicle(5, 1) + 0;
	                    end
	               end   
	            end  

	            % Remove results showing 0 SoC when EV disconnected  
	            if(current_vehicle(5, 1) == 0)
	              current_vehicle(5,1) = NaN;
	            end


	            % Record Vehicle Status
	            fleet_data(1:9, vehicle_num) = current_vehicle(1:9, 1);
	            FleetCharging(hour, vehicle_num) = fleet_data(6, vehicle_num);
	            fleet_SoC(hour, vehicle_num) = fleet_data(5, vehicle_num);
	            fleet_Priority(hour, vehicle_num) = priority;
	        end
	               
	end

	%% Record Results for export
	for x_hour = 1:24  
	  %Hour of Day
	  temp_result(x_hour, 1) = x_hour-1;
	  %Vehicles at Home
	  temp_result(x_hour, 2) = fleet_Size - sum(FleetCharging(x_hour, :)==0);
	  %Vehicles Charging
	  temp_result(x_hour, 3) = sum(FleetCharging(x_hour, :) == 1);
	  %Vehicles Not Charging
	  temp_result(x_hour, 4) = sum(FleetCharging(x_hour, :) == 2);
	    %Vehicles was Charging - Now Injecting
	    temp_result(x_hour, 5) = sum(FleetCharging(x_hour, :) == 3);
	    %Vehicles was Not Charging - Now Injecting
	    temp_result(x_hour, 6) = sum(FleetCharging(x_hour, :) == 4);
	    %Vehicles was Charging - Now Charging
	    temp_result(x_hour, 7) = sum(FleetCharging(x_hour, :) == 5);
	    %Vehicles was Not Charging - Now Charging
	    temp_result(x_hour, 8) = sum(FleetCharging(x_hour, :) == 6);
	end 
	result = temp_result;

	%%  Display Results
	    for temp_hour = 1:24
	       plot_time(temp_hour, 1) = temp_hour-1;
	    end

	  %% Plot random vehicles SoC to check algorithm
	  vehicle1 = 006;
	  vehicle2 = 007;
	    vehicle3 = 3006;
	    vehicle4 = 3008;
	    if (DSR_direction == 0)
	        s_DSR = string('No Service');
	    elseif (DSR_direction == 1)
	        s_DSR = string('Demand Turn Down');
	    elseif (DSR_direction == 2)
	        s_DSR = string('Demand Turn Up');
	    end
	  figure
	  plot(plot_time, fleet_SoC(:, vehicle1) , plot_time, fleet_SoC(:, vehicle2) , plot_time, fleet_SoC(:, vehicle3) , plot_time, fleet_SoC(:, vehicle4) )
	  legend('Vehicle 1 ASAP','Vehicle 2 ASAP','Vehicle 3 ALAP', 'Vehicle 4 ALAP')
	    legend('Location','southeast')
	    axis([0 24 0 1]);
	    s_title = '{\bf\fontsize{14} Vehicle State of Charge under Demand Response Activation}';
	    s_subTitle = 'DSR Service: ' + s_DSR + ' Time:' + string(DSR_hour-1) + ':00 - ' + string(DSR_hour+DSR_duration-0.99) + ':00' ;
	    title( {s_title;s_subTitle},'FontWeight','Normal' )
	    xlabel('Time of Day (hr)') 
	    ylabel('Vehicle State of Charge') 
	    s_filename = 'DSR_Vehicle_SoC '+ s_DSR + ' ' + string(DSR_hour-1);
	    if save_img
	        print(s_filename ,'-dpng')
	    end
	    close


	  % Plot Histogram of maximum SoC to check how many vehicles were not charged
	    Dep_Soc(1, fleet_Size) = 0;
	    for temp = 1:fleet_Size
	        temp2 = t_dep_hour(1,temp) - 1;
	        if (temp2 <= 0)
	            temp2 = temp2 + 24;
	        end
	        Dep_Soc(1, temp) = fleet_SoC(temp2, temp);
	    end
	  figure;
	  histogram(Dep_Soc)
	    s_title = '{\bf\fontsize{14} Fleet SoC Distribution under Demand Response Activation}';
	    s_subTitle = 'DSR Service: ' + s_DSR + ' Time:' + string(DSR_hour-1) + ':00 - ' + string(DSR_hour+DSR_duration-0.99) + ':00' ;
	    title( {s_title;s_subTitle},'FontWeight','Normal' ) 
	    ylabel('Vehicle State of Charge') 
	    axis([0 1 0 fleet_Size]);
	    s_filename = 'DSR_Fleet Soc Distribution '+ s_DSR + ' ' + string(DSR_hour-1);
	    if save_img
	        print(s_filename ,'-dpng')
	    end
	    close
	    hault = 1;
end

function result = DSR_Analyse(input_criteria)
	%%Function Details
	%Run simulation for every hour of day
	%Date Created: 14-04-2018
	%Date last edited: 15-04-2018

	%% Simulation Details			
	%input_criteria = [DSR_duration, fleet_Size, ChargeRate, BatSize, StartSoC, Req_SoC, save_img]


	% result is returns 2:24 array
	% result(1, :) = Demand turn Down response for 24 hours
	% result(2, :) = Demand turn Up response for 24 hours
	%---------------------------------------------------------------------------------------

	DSR_hour = 1; %Will be changed in loop below
	DSR_duration = input_criteria(1,1);
	fleet_Size = input_criteria(1,2);
	ChargeRate = input_criteria(1,3);
	BatSize = input_criteria(1,4);
	StartSoC = input_criteria(1,5); 
	Req_SoC = input_criteria(1,6);
	save_img = input_criteria(1,7);

	%To address issues with indexing for hours starting 0:00 have used this for plotting results
	results_hours = linspace(0,23,24);

	%% Run Simulation for Demand Turn Down every hour of the day
	DSR_direction = 1;
	for x = 1:24
		DSR_hour = x;
		DSR_details = [DSR_hour, DSR_direction, DSR_duration, ChargeRate, fleet_Size, StartSoC, Req_SoC, BatSize];
		sim_results = DSR_Charge(DSR_details);

		%sim_results = 24:8
		%sim_results(:, 1) = hour of day
		%sim_results(:, 2) = Vehicles at Home
		%sim_results(:, 3) = Vehicles Charging     - No DSR
		%sim_results(:, 4) = Vehicles Not Charging - No DSR
		%sim_results(:, 5) = Vehicles was Charging     - Now Not Charging
		%sim_results(:, 6) = Vehicles was Not Charging - Now Not Charging 	--- This is a useless state but left in to keep symmetry
		%sim_results(:, 7) = Vehicles was Charging     - Now Charging    	--- This is a useless state but left in to keep symmetry
		%sim_results(:, 8) = Vehicles was Not Charging - Now Charging

		%% Save Results For Evaluation
		%Simulation Details
		sim_details(x, :) = DSR_details();

		%Simulation Results
		sim_vehicles_home(:, 1) = sim_results(:, 2);
		sim_charging(:, 1) = sim_results(:, 3);
		sim_not_charging(:, 1) = sim_results(:, 4);

		%Demand Turn Down = 1*(Charge -> Not-Charge[5]) + 0*(Not-Charge -> Not-Charge[6])
		%Demand Turn Up   = 0*(Charge -> Charge[7]) + 1*(Not-Charge -> Charge[8])
		sim_DTD(:, 1) = 1*sim_results(:, 5) + 0*sim_results(:, 6) ;
		sim_DTU(:, 1) = 0*sim_results(:, 7) + 1*sim_results(:, 8) ;

		%Power Demand = Charging[3] + Demand Turn Up[8] 
		sim_Power = sim_results(:, 3) + sim_results(:, 8);

		%Save Results for Comparison Plot
		results_DTD(x, 1) = sim_DTD(x, 1);


		%make results square to plot better
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

		% Create Plot for Power and Service Availability  
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
	    		print('DSR_Turn_Down_' + string(x) ,'-dpng')
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
		sim_results = DSR_Charge(DSR_details);

		%sim_results = 24:8
		%sim_results(:, 1) = hour of day
		%sim_results(:, 2) = Vehicles at Home
		%sim_results(:, 3) = Vehicles Charging     - No DSR
		%sim_results(:, 4) = Vehicles Not Charging - No DSR
		%sim_results(:, 5) = Vehicles was Charging     - Now Not Charging
		%sim_results(:, 6) = Vehicles was Not Charging - Now Not Charging 	--- This is a useless state but left in to keep symmetry
		%sim_results(:, 7) = Vehicles was Charging     - Now Charging    	--- This is a useless state but left in to keep symmetry
		%sim_results(:, 8) = Vehicles was Not Charging - Now Charging

		%% Save Results For Evaluation
		%Simulation Details
		sim_details(x, :) = DSR_details();

		%Simulation Results
		sim_vehicles_home(:, 1) = sim_results(:, 2);
		sim_charging(:, 1) = sim_results(:, 3);
		sim_not_charging(:, 1) = sim_results(:, 4);

		%Demand Turn Down = 1*(Charge -> Not-Charge[5]) + 0*(Not-Charge -> Not-Charge[6])
		%Demand Turn Up   = 0*(Charge -> Charge[7]) + 1*(Not-Charge -> Charge[8])
		sim_DTD(:, 1) = 1*sim_results(:, 5) + 0*sim_results(:, 6) ;
		sim_DTU(:, 1) = 0*sim_results(:, 7) + 1*sim_results(:, 8) ;

		%Power Demand = Charging[3] + Demand Turn Up[8] 
		sim_Power = sim_results(:, 3) + sim_results(:, 8);

		%Save Results for Comparison Plot
		results_DTU(x, 1) = sim_DTU(x, 1);


		%make results square to plot better
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

		% Create Plot for Power and Service Availability  
			var1 = sim_vehicles_home/fleet_Size * 100;
			var2 = sim_Power2*ChargeRate/1000;
			var3 = sim_charging2*ChargeRate/1000;
			var4 = sim_not_charging2*ChargeRate/1000;
			var5 = sim_DTU2*ChargeRate/1000;
			Power_Demand_Turn_Down(:, x) = var2;

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
	    		print('DSR_Turn_Up_' + string(x) ,'-dpng')
			end
			close

		% %Plot Non Square Results From Individual Simulation
		% 	figure
		% 	plot(results_hours, (sim_vehicles_home), results_hours, (sim_charging), results_hours, (sim_not_charging), results_hours, (sim_DTD), results_hours, (sim_DTU)) 
		% 	xlabel('Time of Day (hr)') 
		% 	ylabel('Number of Vehicles') 
		% 	legend('Vehicles at Home', 'Vehicles Charging', 'Vehicles Not Charging', 'Demand Turn Down', 'Demand Turn Up')
	end

	%% Run Simulation for No Service once
	DSR_direction = 0;
	for x = 1:1
		DSR_hour = x;
		DSR_details = [DSR_hour, DSR_direction, DSR_duration, ChargeRate, fleet_Size, StartSoC, Req_SoC, BatSize];
		sim_results = DSR_Charge(DSR_details);

		%sim_results = 24:8
		%sim_results(:, 1) = hour of day
		%sim_results(:, 2) = Vehicles at Home
		%sim_results(:, 3) = Vehicles Charging     - No DSR
		%sim_results(:, 4) = Vehicles Not Charging - No DSR
		%sim_results(:, 5) = Vehicles was Charging     - Now Not Charging
		%sim_results(:, 6) = Vehicles was Not Charging - Now Not Charging 	--- This is a useless state but left in to keep symmetry
		%sim_results(:, 7) = Vehicles was Charging     - Now Charging    	--- This is a useless state but left in to keep symmetry
		%sim_results(:, 8) = Vehicles was Not Charging - Now Charging

		%% Save Results For Evaluation
		%Simulation Details
		sim_details(x, :) = DSR_details();

		%Simulation Results
		sim_vehicles_home(:, 1) = sim_results(:, 2);
		sim_charging(:, 1) = sim_results(:, 3);
		sim_not_charging(:, 1) = sim_results(:, 4);

		%Demand Turn Down = 1*(Charge -> Not-Charge[5]) + 0*(Not-Charge -> Not-Charge[6])
		%Demand Turn Up   = 0*(Charge -> Charge[7]) + 1*(Not-Charge -> Charge[8])
		sim_DTD(:, 1) = 1*sim_results(:, 5) + 0*sim_results(:, 6) ;
		sim_DTU(:, 1) = 0*sim_results(:, 7) + 1*sim_results(:, 8) ;

		%Power Demand = Charging[3] + Demand Turn Up[8] 
		sim_Power = sim_results(:, 3) + sim_results(:, 8);


		%make results square to plot better
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

		% Create Plot for Power and Service Availability  
			var1 = sim_vehicles_home/fleet_Size * 100;
			var2 = sim_Power2*ChargeRate/1000;
			var3 = sim_charging2*ChargeRate/1000;
			var4 = sim_not_charging2*ChargeRate/1000;
			Power_Demand_Turn_Down(:, x) = var2;

			svar1 = 'Vehicles Home';
			svar2 = 'Power Demand';
			svar3 = 'Available Turn Up';
			svar4 = 'Available Turn Down';

			figure
			yyaxis right
			p = plot(results_hours, (var1));
			p(1).LineWidth = 2;
			ylabel('Percentage of Fleet Plugged In') 
			axis([0 24 -100 100])
			hold on

			yyaxis left
			q = plot(results_hours2, (var2), results_hours2, (var3), results_hours2, (var4)) ;
			q(1).LineWidth = 2;
			axis([0 24 -ChargeRate*fleet_Size/1000 ChargeRate*fleet_Size/1000])
			% area(results_hours2,sim_DTD2*ChargeRate/1000,'DisplayName','plot_data4','LineWidth',0.1);
			legend(svar2, svar3, svar4)
			s_title = '{\bf\fontsize{14} Power usage of Vehicle Fleet under Demand Response Activation}';
			s_subTitle = 'DSR Service: No Service' ;
			title( {s_title;s_subTitle},'FontWeight','Normal' )
			xlabel('Time of Day (hr)') 
			ylabel('Power (MW)') 
			if save_img
	    		print('DSR_No_Service' ,'-dpng')
			end
			close

		% %Plot Non Square Results From Individual Simulation
		% 	figure
		% 	plot(results_hours, (sim_vehicles_home), results_hours, (sim_charging), results_hours, (sim_not_charging), results_hours, (sim_DTD), results_hours, (sim_DTU)) 
		% 	xlabel('Time of Day (hr)') 
		% 	ylabel('Number of Vehicles') 
		% 	legend('Vehicles at Home', 'Vehicles Charging', 'Vehicles Not Charging', 'Demand Turn Down', 'Demand Turn Up')
	end


	%% Plot Results From All Simulations
	% Plot DTU and DTD Achieved for hour of day
	figure
	plot(results_hours, results_DTD*ChargeRate/1000, results_hours, results_DTU*ChargeRate/1000) 
	s_title = '{\bf\fontsize{14} DSR Power vs Time of Day : Uni-Directional}';
	s_subTitle =  'Vehicle Fleet of ' + string(fleet_Size) + '  ' + string(ChargeRate) + 'kW EVs' ;
	title( {s_title;s_subTitle},'FontWeight','Normal')
	axis([0 24 0 25])
	xlabel('Time of Day (hr)') 
	ylabel('Power (MW)') 
	legend('Demand Turn Down', 'Demand Turn Up')		
	if save_img
		print('DSR Results' ,'-dpng')
	end
	close

	%% Save Results
	temp_result(1, :) = results_DTD;
	temp_result(2, :) = results_DTU;
	result = temp_result
end

%% ---------------------------------------------------------------------------------------
% 	DSR Charging with bi-diectional chargers (V2G)
%---------------------------------------------------------------------------------------
function result = V2G_Charge(DSR_specs)
	%% Simulation Details
	% DSR_hour is the hour the service is called upon
	% DSR_direction is the service required: 0= no service, 1= turn down,
	% 2=turn up

	DSR_hour = DSR_specs(1,1);
	DSR_direction = DSR_specs(1,2);
	DSR_duration = DSR_specs(1,3);
	save_img = 1;

	%% Fleet Definitions
	for n = 1
		%fleet def = [fleet_Size, StartSoC, Req_SoC, BatSize, ChargeRate]
		fleet_def = [DSR_specs(1,5), DSR_specs(1,6), DSR_specs(1,7), DSR_specs(1,8), DSR_specs(1,4)];
		fleet_Size = fleet_def(1, 1);
		StartSoC = fleet_def(1, 2);
		Req_SoC = fleet_def(1, 3);
		BatSize = fleet_def(1, 4);
		ChargeRate = fleet_def(1, 5);
		DSR_duration = DSR_duration - 0.01;

		% Produce arrival and departue times using normal data
		rng('default') % For reproducibility
		%Arrival Times
		fleet_data(1, 1:fleet_Size) = normrnd(19.16,3.62,[fleet_Size, 1]);
		%Departure Time
		fleet_data(2, 1:fleet_Size) = normrnd(10.53,3.26,[fleet_Size, 1]);
		%Start SoC  
		fleet_data(3, 1:fleet_Size) = StartSoC; 
		%Required SoC
		fleet_data(4, 1:fleet_Size) = Req_SoC; 
	    %Set required SoC to be one hour charge higher than for ASAP
	        %Removing for now as ruins energy calculations
	        %fleet_data(4, fleet_Size/2:fleet_Size) = Req_SoC + ChargeRate/BatSize;
		%Current SoC
		fleet_data(5, 1:fleet_Size) = StartSoC;
		%Current State
		fleet_data(6, 1:fleet_Size) = 0;
		%Priority
		fleet_data(7, 1:fleet_Size) = 0;
		%Battery Size (kWh)
		fleet_data(8, 1:fleet_Size) = BatSize;
		%Charge Rate (kW)
		fleet_data(9, 1:fleet_Size) = ChargeRate;
		%Other


	   %As day is continuous need to move times greater than 24 to next morning
		for x = 1 : length(fleet_data)
		    if  (fleet_data(1,x) >= 24)
		      fleet_data(1,x) = fleet_data(1,x) - 24 ;
		    end
		    if  (fleet_data(2,x) >= 24)
		      fleet_data(2,x) = fleet_data(2,x) - 24 ;
	  	  	end
		end 

		% % Plot Histogram of arrivals and departures to make sure all times are <24h
		% figure;
		% yyaxis right
		% histogram(fleet_data(1,:),'BinWidth',0.5)
		% hold on
		% histogram(fleet_data(2,:),'BinWidth',0.5)
		% hold off
		% hold on
		% yyaxis left
		% fleet_ASAP = Charge_MidP(fleet_data);
		% plot(fleet_ASAP(1:24, 1), fleet_ASAP(1:24, 6))
		% hold off
		% legend('Vehicles at Home', 'Arrival', 'Departure')
		% title('Arrival and Departure distribution of fleet')
		% xlabel('Hour of Day') 
		% ylabel('Number of Vehicles') 
		% % print('Arrival and Departure Times','-dpng')
		% % close
	end

	%% Setup Simulation Variables
		FleetCharging(24, fleet_Size) = 0;
		FleetChargingDSR(24, fleet_Size) = 0;   
	%% Calculate 1/2 of fleet using ASAP Priority
	for vehicle_num = 1 : length(fleet_data)/2
	    %extract variables for vehicle
	    current_vehicle(1:9, 1) = fleet_data(1:9, vehicle_num);
	    t_arr =  current_vehicle(1, 1);
	    t_dep = current_vehicle(2, 1);
	    start_SoC = current_vehicle(3, 1);
	    req_SoC = current_vehicle(4, 1);
	    curr_SoC = current_vehicle(5, 1);
	    bev_state = current_vehicle(6, 1);
	    batt_size = current_vehicle(8, 1);
	    charge_rate = current_vehicle(9, 1);

	    hour_start = ceil(t_arr);
	    t_dep_hour(vehicle_num) = ceil(t_dep);
	    
	        for hour_t = hour_start : 24
	        	hour = hour_t;
	            %Check vehicle is at home
	            for temp_half_hour = 1:1
	                   time = hour;
	                   if ((t_arr <= time)  &&  (time <= t_dep))
	                       %if( home ) then state = -1
	                       current_vehicle(6,1) = -1; 
	                   elseif(  (t_dep < t_arr) && (time > t_arr)  )
	                       current_vehicle(6,1) = -1; 
	                   elseif(  (t_dep < t_arr) && (time < t_dep)  )
	                       current_vehicle(6,1) = -1; 
	                   else %else give state = 0
	                       	current_vehicle(6,1) = 0; 
	                   		%give current SoC = NaN
	                   		current_vehicle(5, 1) = NaN;
	                        curr_SoC = NaN;
	                   end
	                   bev_state = current_vehicle(6, 1);
	            end

	            %Calculate time plugged in
	            for temp_half_hour = 1:1
	                t_plugged_in = hour-t_arr;
	                if (t_plugged_in<0)
	                    t_plugged_in = t_plugged_in + 24;
	                end
	            end

	            %Calculate time remaining plugged in
	            for temp_half_hour = 1:1
	                if ((t_dep< t_arr) && (t_dep < hour))
	                 t_rem = t_dep-hour + 24;           
	                else
	                 t_rem = t_dep-hour;                    
	                end
	            end

	            %Calculate Laxity
	            for temp_half_hour = 1:1
	            	curr_SoC = current_vehicle(5, 1);
	                t_charge = (req_SoC-curr_SoC)*batt_size/charge_rate;
	                t_laxity =  t_rem - t_charge ;
	                %if laxity is negative set to 0
	                if (t_laxity < 0)

	                    t_laxity = 0;
	                end
	            end

	            %Set Priority of Vehicle
	            for temp_half_hour = 1:1
	                if (bev_state == 0)             						%If not plugged in
	                    %Set Priority to 0
	                    priority = 0;  
	                    %Set Laxity to Max
	                    t_laxity = 24;

	                elseif(req_SoC >= curr_SoC+charge_rate/batt_size)      	%Charge Vehicle
	                    %Set Priority to 100
	                    priority = 100;   
	                    

	                elseif(curr_SoC <= 1- charge_rate/batt_size)   			% If Not fully Charged and available for DTU  
	                    %Set Priority to 0
	                    priority = 10;  
	                    %Set Laxity to Max
	                    t_laxity = 24;   
	                else 													% If Fully Charged and not available for DTU  
	                    %Set Priority to 0
	                    priority = 0;  
	                    %Set Laxity to Max
	                    t_laxity = 24;   
	                   	   
	                end
	            end

	            %Charge Vehicles
	            for temp_half_hour = 1:1
	               cutoff_priority = 80;
	               current_vehicle(5, 1) = curr_SoC;
	               if ((DSR_hour <= hour) && (DSR_hour + DSR_duration >= hour)) % If within the DSR window
	               		if (DSR_direction == 0) %No DSR Service Called
		                    if (bev_state == 0) % Not Plugged In
		                        %State = Not Plugged in
		                        current_vehicle(6, 1) = 0;
	 
		                    elseif (priority < 10) %Do not Charge
		                        %State = Not Charging
		                        current_vehicle(6, 1) = 2;
		                        %Current SoC = Current SoC
		                        current_vehicle(5, 1) = current_vehicle(5, 1) + 0;

		                    elseif (priority >= cutoff_priority) %Above cutoff : Charge
		                        %State = Charging
		                        current_vehicle(6, 1) = 1;
		                        %Current SoC = Current SoC + hour of charge
		                        current_vehicle(5, 1) = current_vehicle(5, 1) + charge_rate/batt_size;

		                    else
		                        % Below cutoff for charge
		                        %State = Plugged in Not Charging
		                        current_vehicle(6, 1) = 2;
		                        %Current SoC = Current SoC;
		                        current_vehicle(5, 1) = current_vehicle(5, 1) + 0;
		                    end
		            	
		            	elseif (DSR_direction == 1) % Demand Turn Down - stop charging and reverse
		                    if (bev_state == 0) % Not Plugged In
		                        %State = Not Plugged in
		                        current_vehicle(6, 1) = 0;

		                    elseif (priority <= 0) %Too full to charge : Inject
		                        %State = Was Not Charging, Now Injecting
		                        current_vehicle(6, 1) = 4;
		                        %Current SoC = Current SoC - hour of charge
		                        current_vehicle(5, 1) = current_vehicle(5, 1) - charge_rate/batt_size;

		                    elseif (priority >= cutoff_priority) %Above cutoff, Should Charge : Injecting
	                            %State = Was Charging, Now Injecting
	                            current_vehicle(6, 1) = 3;
	                            %Current SoC = Current SoC - hour of charge
	                            current_vehicle(5, 1) = current_vehicle(5, 1) - charge_rate/batt_size;

		                    else % Below cutoff for charge : Injecting
	                            %State = Was Not Charging, Now Injecting
	                            current_vehicle(6, 1) = 4;
	                            %Current SoC = Current SoC - hour of charge
	                            current_vehicle(5, 1) = current_vehicle(5, 1) - charge_rate/batt_size;
		                    end

		            	elseif (DSR_direction == 2) % Demand Turn Up - start charging those waiting
		                    if (bev_state == 0) % Not Plugged In
		                        %State = Not Plugged in
		                        current_vehicle(6, 1) = 0;

		                    elseif (priority < 10) %Do not Charge - full battery
		                        %State = Not Charging
		                        current_vehicle(6, 1) = 2;
		                        %Current SoC = Current SoC
		                        current_vehicle(5, 1) = current_vehicle(5, 1) + 0;

		                    elseif (priority >= cutoff_priority) %Above cutoff : Charge like normal
		                        %State = Charging
		                        current_vehicle(6, 1) = 1;
		                        %Current SoC = Current SoC + hour of charge
		                        current_vehicle(5, 1) = current_vehicle(5, 1) + charge_rate/batt_size;

		                    else % Below cutoff for charge : Normally do not charge, now demand turn up
		                        %State = Demand turn Up
		                        current_vehicle(6, 1) = 6;
		                        %Current SoC = Current SoC + hour of charge
		                        current_vehicle(5, 1) = current_vehicle(5, 1) + charge_rate/batt_size;
		                    end
						
						end

	                else %Act as if normal because outside DSR window
	                    if (bev_state == 0) % Not Plugged In
	                        %State = Not Plugged in
	                        current_vehicle(6, 1) = 0;

	                    elseif (priority <= 0) %Do not Charge
	                        %State = Not Charging
	                        current_vehicle(6, 1) = 2;
	                        %Current SoC = Current SoC
	                        current_vehicle(5, 1) = current_vehicle(5, 1) + 0;

	                    elseif (priority >= cutoff_priority) %Above cutoff : Charge
	                        %State = Charging
	                        current_vehicle(6, 1) = 1;
	                        %Current SoC = Current SoC + hour of charge
	                        current_vehicle(5, 1) = current_vehicle(5, 1) + charge_rate/batt_size;

	                    else % Below cutoff for charge
	                        %State = Plugged in Not Charging
	                        current_vehicle(6, 1) = 2;
	                        %Current SoC = Current SoC;
	                        current_vehicle(5, 1) = current_vehicle(5, 1) + 0;
						end
	                end  	
	            end  

	            % Remove results showing 0 SoC when EV disconnected  
	            if (current_vehicle(5, 1) == 0)
	                current_vehicle(5,1) = NaN;
	            end

	            % Record Vehicle Status
	            fleet_data(1:9, vehicle_num) = current_vehicle(1:9, 1);
	            FleetCharging(hour, vehicle_num) = fleet_data(6, vehicle_num);
	            fleet_SoC(hour, vehicle_num) = fleet_data(5, vehicle_num);
	            fleet_Priority(hour, vehicle_num) = priority;
			end
		

	       for hour_t = 1 : hour_start-1
	            hour = hour_t;
	            %Check vehicle is at home
	            for temp_half_hour = 1:1
	                   time = hour;
	                   if ((t_arr <= time)  &&  (time <= t_dep))
	                       %if( home ) then state = -1
	                       current_vehicle(6,1) = -1; 
	                   elseif(  (t_dep < t_arr) && (time > t_arr)  )
	                       current_vehicle(6,1) = -1; 
	                   elseif(  (t_dep < t_arr) && (time < t_dep)  )
	                       current_vehicle(6,1) = -1; 
	                   else %else give state = 0
	                        current_vehicle(6,1) = 0; 
	                        %give current SoC = 0
	                        current_vehicle(5, 1) = 0;
	                   end
	                   bev_state = current_vehicle(6, 1);
	            end

	            %Calculate time plugged in
	            for temp_half_hour = 1:1
	                t_plugged_in = hour-t_arr;
	                if (t_plugged_in<0)
	                    t_plugged_in = t_plugged_in + 24;
	                end
	            end

	            %Calculate time remaining plugged in
	            for temp_half_hour = 1:1
	                if ((t_dep< t_arr) && (t_dep < hour))
	                 t_rem = t_dep-hour + 24;           
	                else
	                 t_rem = t_dep-hour;                    
	                end
	            end

	            %Calculate Laxity
	            for temp_half_hour = 1:1
	                curr_SoC = current_vehicle(5, 1);
	                t_charge = (req_SoC-curr_SoC)*batt_size/charge_rate;
	                t_laxity =  t_rem - t_charge ;
	                %if laxity is negative set to 0
	                if (t_laxity < 0)

	                    t_laxity = 0;
	                end
	            end

	            %Set Priority of Vehicle
	            for temp_half_hour = 1:1
	                if (bev_state == 0)                                     %If not plugged in
	                    %Set Priority to 0
	                    priority = 0;  
	                    %Set Laxity to Max
	                    t_laxity = 24;

	                elseif(req_SoC >= curr_SoC+charge_rate/batt_size)       %Charge Vehicle
	                    %Set Priority to 100
	                    priority = 100;   
	                    

	                elseif(curr_SoC <= 1- charge_rate/batt_size)            % If Not fully Charged and available for DTU  
	                    %Set Priority to 0
	                    priority = 10;  
	                    %Set Laxity to Max
	                    t_laxity = 24;   
	                else                                                    % If Fully Charged and not available for DTU  
	                    %Set Priority to 0
	                    priority = 0;  
	                    %Set Laxity to Max
	                    t_laxity = 24;   
	                       
	                end
	            end

	            %Charge Vehicles
	            for temp_half_hour = 1:1
	               cutoff_priority = 80;
	               current_vehicle(5, 1) = curr_SoC;
	               if ((DSR_hour <= hour) && (DSR_hour + DSR_duration >= hour)) % If within the DSR window
	                    if (DSR_direction == 0) %No DSR Service Called
	                        if (bev_state == 0) % Not Plugged In
	                            %State = Not Plugged in
	                            current_vehicle(6, 1) = 0;
	 
	                        elseif (priority < 10) %Do not Charge
	                            %State = Not Charging
	                            current_vehicle(6, 1) = 2;
	                            %Current SoC = Current SoC
	                            current_vehicle(5, 1) = current_vehicle(5, 1) + 0;

	                        elseif (priority >= cutoff_priority) %Above cutoff : Charge
	                            %State = Charging
	                            current_vehicle(6, 1) = 1;
	                            %Current SoC = Current SoC + hour of charge
	                            current_vehicle(5, 1) = current_vehicle(5, 1) + charge_rate/batt_size;

	                        else
	                            % Below cutoff for charge
	                            %State = Plugged in Not Charging
	                            current_vehicle(6, 1) = 2;
	                            %Current SoC = Current SoC;
	                            current_vehicle(5, 1) = current_vehicle(5, 1) + 0;
	                        end
	                    
	                    elseif (DSR_direction == 1) % Demand Turn Down - stop charging and reverse
	                        if (bev_state == 0) % Not Plugged In
	                            %State = Not Plugged in
	                            current_vehicle(6, 1) = 0;

	                        elseif (priority <= 0) %Too full to charge : Inject
	                            %State = Was Not Charging, Now Injecting
	                            current_vehicle(6, 1) = 4;
	                            %Current SoC = Current SoC - hour of charge
	                            current_vehicle(5, 1) = current_vehicle(5, 1) - charge_rate/batt_size;

	                        elseif (priority >= cutoff_priority) %Above cutoff, Should Charge : Injecting
	                            %State = Was Charging, Now Injecting
	                            current_vehicle(6, 1) = 3;
	                            %Current SoC = Current SoC - hour of charge
	                            current_vehicle(5, 1) = current_vehicle(5, 1) - charge_rate/batt_size;

	                        else % Below cutoff for charge : Injecting
	                            %State = Was Not Charging, Now Injecting
	                            current_vehicle(6, 1) = 4;
	                            %Current SoC = Current SoC - hour of charge
	                            current_vehicle(5, 1) = current_vehicle(5, 1) - charge_rate/batt_size;
	                        end

	                    elseif (DSR_direction == 2) % Demand Turn Up - start charging those waiting
	                        if (bev_state == 0) % Not Plugged In
	                            %State = Not Plugged in
	                            current_vehicle(6, 1) = 0;

	                        elseif (priority < 10) %Do not Charge - full battery
	                            %State = Not Charging
	                            current_vehicle(6, 1) = 2;
	                            %Current SoC = Current SoC
	                            current_vehicle(5, 1) = current_vehicle(5, 1) + 0;

	                        elseif (priority >= cutoff_priority) %Above cutoff : Charge like normal
	                            %State = Charging
	                            current_vehicle(6, 1) = 1;
	                            %Current SoC = Current SoC + hour of charge
	                            current_vehicle(5, 1) = current_vehicle(5, 1) + charge_rate/batt_size;

	                        else % Below cutoff for charge : Normally do not charge, now demand turn up
	                            %State = Demand turn Up
	                            current_vehicle(6, 1) = 6;
	                            %Current SoC = Current SoC + hour of charge
	                            current_vehicle(5, 1) = current_vehicle(5, 1) + charge_rate/batt_size;
	                        end
	                    
	                    end

	               else %Act as if normal because outside DSR window
	                    if (bev_state == 0) % Not Plugged In
	                        %State = Not Plugged in
	                        current_vehicle(6, 1) = 0;

	                    elseif (priority <= 0) %Do not Charge
	                        %State = Not Charging
	                        current_vehicle(6, 1) = 2;
	                        %Current SoC = Current SoC
	                        current_vehicle(5, 1) = current_vehicle(5, 1) + 0;

	                    elseif (priority >= cutoff_priority) %Above cutoff : Charge
	                        %State = Charging
	                        current_vehicle(6, 1) = 1;
	                        %Current SoC = Current SoC + hour of charge
	                        current_vehicle(5, 1) = current_vehicle(5, 1) + charge_rate/batt_size;

	                    else % Below cutoff for charge
	                        %State = Plugged in Not Charging
	                        current_vehicle(6, 1) = 2;
	                        %Current SoC = Current SoC;
	                        current_vehicle(5, 1) = current_vehicle(5, 1) + 0;
	                    end
	               end                 
	            end

	            % Remove results showing 0 SoC when EV disconnected  
	            if (current_vehicle(5, 1) == 0)
	                current_vehicle(5,1) = NaN;
	            end

	            % Record Vehicle Status
	            fleet_data(1:9, vehicle_num) = current_vehicle(1:9, 1);
	            FleetCharging(hour, vehicle_num) = fleet_data(6, vehicle_num);
	            fleet_SoC(hour, vehicle_num) = fleet_data(5, vehicle_num);
	            fleet_Priority(hour, vehicle_num) = priority;
	       end          
	end

	%% Calculate 1/2 of fleet using ALAP Priority
	for vehicle_num =  length(fleet_data)/2+1 :  length(fleet_data)
	    %extract variables for vehicle
	    current_vehicle(1:9, 1) = fleet_data(1:9, vehicle_num);
	    t_arr =  current_vehicle(1, 1);
	    t_dep = current_vehicle(2, 1);
	    start_SoC = current_vehicle(3, 1);
	    req_SoC = current_vehicle(4, 1);
	    curr_SoC = current_vehicle(5, 1);
	    bev_state = current_vehicle(6, 1);
	    batt_size = current_vehicle(8, 1);
	    charge_rate = current_vehicle(9, 1);

	    hour_start = ceil(t_arr);
	    t_dep_hour(vehicle_num) = ceil(t_dep);
	    laxity_cutoff = 0.1;
	    
	        for hour_t = hour_start : 24
	        	hour = hour_t;
	            %Check vehicle is at home
	            for temp_half_hour = 1:1
	                   time = hour;
	                   if ((t_arr <= time)  &&  (time <= t_dep))
	                       %if( home ) then state = -1
	                       current_vehicle(6,1) = -1; 
	                   elseif(  (t_dep < t_arr) && (time > t_arr)  )
	                       current_vehicle(6,1) = -1; 
	                   elseif(  (t_dep < t_arr) && (time < t_dep)  )
	                       current_vehicle(6,1) = -1; 
	                   else %else give state = 0
	                       	current_vehicle(6,1) = 0; 
	                   		%give current SoC = 0
	                   		current_vehicle(5, 1) = 0;
	                   end
	                   bev_state = current_vehicle(6, 1);
	            end

	            %Calculate time plugged in
	            for temp_half_hour = 1:1
	                t_plugged_in = hour-t_arr;
	                if (t_plugged_in<0)
	                    t_plugged_in = t_plugged_in + 24;
	                end
	            end

	            %Calculate time remaining plugged in
	            for temp_half_hour = 1:1
	                if ((t_dep< t_arr) && (t_dep < hour))
	                 t_rem = t_dep-hour + 24;           
	                else
	                 t_rem = t_dep-hour;                    
	                end
	            end

	            %Calculate Laxity
	            for temp_half_hour = 1:1
	            	curr_SoC = current_vehicle(5, 1);
	                t_charge = (req_SoC-curr_SoC)*batt_size/charge_rate;
	                t_laxity =  t_rem - t_charge +1 ;
	                %if laxity is negative set to 0
	                if (t_laxity < 0)

	                    t_laxity = 0;
	                end
	            end

	            %Set Priority of Vehicle 
	            for temp_half_hour = 1:1
	            	if (bev_state == 0)             %If not plugged in
		            	%Set Priority to 0
		            	priority = 0;  
		            	%Set Laxity to Max
		            	t_laxity = 24;
	                
	       			elseif(t_laxity < laxity_cutoff)         %If Laxity less than 1 hour: Charge
	            		%Set Priority to 100
	            		priority = 100;  

	            	elseif(curr_SoC <= 1-charge_rate/batt_size)  % Not Chraging but available for DTU  
	                    %Set Priority to 0
	                    priority = 10;  
	                    %Set Laxity to Max
	                    t_laxity = 24;   
	        		else                            %Else Vehicle Fully Charged 
	            		%Set Priority to 0
	            		priority = 0;  
	    			end
	            end

	            %Charge Vehicles
	            for temp_half_hour = 1:1
	               cutoff_priority = 80;
	               current_vehicle(5, 1) = curr_SoC;
	               if ((DSR_hour <= hour) && (DSR_hour + DSR_duration >= hour)) % If within the DSR window
	                    if (DSR_direction == 0) %No DSR Service Called
	                        if (bev_state == 0) % Not Plugged In
	                            %State = Not Plugged in
	                            current_vehicle(6, 1) = 0;
	 
	                        elseif (priority < 10) %Do not Charge
	                            %State = Not Charging
	                            current_vehicle(6, 1) = 2;
	                            %Current SoC = Current SoC
	                            current_vehicle(5, 1) = current_vehicle(5, 1) + 0;

	                        elseif (priority >= cutoff_priority) %Above cutoff : Charge
	                            %State = Charging
	                            current_vehicle(6, 1) = 1;
	                            %Current SoC = Current SoC + hour of charge
	                            current_vehicle(5, 1) = current_vehicle(5, 1) + charge_rate/batt_size;

	                        else
	                            % Below cutoff for charge
	                            %State = Plugged in Not Charging
	                            current_vehicle(6, 1) = 2;
	                            %Current SoC = Current SoC;
	                            current_vehicle(5, 1) = current_vehicle(5, 1) + 0;
	                        end
	                    
	                    elseif (DSR_direction == 1) % Demand Turn Down - stop charging and reverse
	                        if (bev_state == 0) % Not Plugged In
	                            %State = Not Plugged in
	                            current_vehicle(6, 1) = 0;

	                        elseif (priority <= 0) %Too full to charge : Inject
	                            %State = Was Not Charging, Now Injecting
	                            current_vehicle(6, 1) = 4;
	                            %Current SoC = Current SoC - hour of charge
	                            current_vehicle(5, 1) = current_vehicle(5, 1) - charge_rate/batt_size;

	                        elseif (priority >= cutoff_priority) %Above cutoff, Should Charge : Injecting
	                            %State = Was Charging, Now Injecting
	                            current_vehicle(6, 1) = 3;
	                            %Current SoC = Current SoC - hour of charge
	                            current_vehicle(5, 1) = current_vehicle(5, 1) - charge_rate/batt_size;

	                        else % Below cutoff for charge : Injecting
	                            %State = Was Not Charging, Now Injecting
	                            current_vehicle(6, 1) = 4;
	                            %Current SoC = Current SoC - hour of charge
	                            current_vehicle(5, 1) = current_vehicle(5, 1) - charge_rate/batt_size;
	                        end

	                    elseif (DSR_direction == 2) % Demand Turn Up - start charging those waiting
	                        if (bev_state == 0) % Not Plugged In
	                            %State = Not Plugged in
	                            current_vehicle(6, 1) = 0;

	                        elseif (priority < 10) %Do not Charge - full battery
	                            %State = Not Charging
	                            current_vehicle(6, 1) = 2;
	                            %Current SoC = Current SoC
	                            current_vehicle(5, 1) = current_vehicle(5, 1) + 0;

	                        elseif (priority >= cutoff_priority) %Above cutoff : Charge like normal
	                            %State = Charging
	                            current_vehicle(6, 1) = 1;
	                            %Current SoC = Current SoC + hour of charge
	                            current_vehicle(5, 1) = current_vehicle(5, 1) + charge_rate/batt_size;

	                        else % Below cutoff for charge : Normally do not charge, now demand turn up
	                            %State = Demand turn Up
	                            current_vehicle(6, 1) = 6;
	                            %Current SoC = Current SoC + hour of charge
	                            current_vehicle(5, 1) = current_vehicle(5, 1) + charge_rate/batt_size;
	                        end
	                    
	                    end

	                else %Act as if normal because outside DSR window
	                    if (bev_state == 0) % Not Plugged In
	                        %State = Not Plugged in
	                        current_vehicle(6, 1) = 0;

	                    elseif (priority <= 0) %Do not Charge
	                        %State = Not Charging
	                        current_vehicle(6, 1) = 2;
	                        %Current SoC = Current SoC
	                        current_vehicle(5, 1) = current_vehicle(5, 1) + 0;

	                    elseif (priority >= cutoff_priority) %Above cutoff : Charge
	                        %State = Charging
	                        current_vehicle(6, 1) = 1;
	                        %Current SoC = Current SoC + hour of charge
	                        current_vehicle(5, 1) = current_vehicle(5, 1) + charge_rate/batt_size;

	                    else % Below cutoff for charge
	                        %State = Plugged in Not Charging
	                        current_vehicle(6, 1) = 2;
	                        %Current SoC = Current SoC;
	                        current_vehicle(5, 1) = current_vehicle(5, 1) + 0;
	                    end
	                end              
	                    
	            end  
	            % Remove results showing 0 SoC when EV disconnected  
	            if (current_vehicle(5, 1) == 0)
	                current_vehicle(5,1) = NaN;
	            end

	            % Record Vehicle Status
	            fleet_data(1:9, vehicle_num) = current_vehicle(1:9, 1);
	            FleetCharging(hour, vehicle_num) = fleet_data(6, vehicle_num);
	            fleet_SoC(hour, vehicle_num) = fleet_data(5, vehicle_num);
	            fleet_Priority(hour, vehicle_num) = priority;
			end
		

	       for hour_t = 1 : hour_start-1
	            hour = hour_t;
	            %Check vehicle is at home
	            for temp_half_hour = 1:1
	                   time = hour;
	                   if ((t_arr <= time)  &&  (time <= t_dep))
	                       %if( home ) then state = -1
	                       current_vehicle(6,1) = -1; 
	                   elseif(  (t_dep < t_arr) && (time > t_arr)  )
	                       current_vehicle(6,1) = -1; 
	                   elseif(  (t_dep < t_arr) && (time < t_dep)  )
	                       current_vehicle(6,1) = -1; 
	                   else %else give state = 0
	                        current_vehicle(6,1) = 0; 
	                        %give current SoC = 0
	                        current_vehicle(5, 1) = 0;
	                   end
	                   bev_state = current_vehicle(6, 1);
	            end

	            %Calculate time plugged in
	            for temp_half_hour = 1:1
	                t_plugged_in = hour-t_arr;
	                if (t_plugged_in<0)
	                    t_plugged_in = t_plugged_in + 24;
	                end
	            end

	            %Calculate time remaining plugged in
	            for temp_half_hour = 1:1
	                if ((t_dep< t_arr) && (t_dep < hour))
	                 t_rem = t_dep-hour + 24;           
	                else
	                 t_rem = t_dep-hour;                    
	                end
	            end

	            %Calculate Laxity
	            for temp_half_hour = 1:1
	                curr_SoC = current_vehicle(5, 1);
	                t_charge = (req_SoC-curr_SoC)*batt_size/charge_rate;
	                t_laxity =  t_rem - t_charge +1;
	                %if laxity is negative set to 0
	                if (t_laxity < 0)

	                    t_laxity = 0;
	                end
	            end

	            %Set Priority of Vehicle 
	            for temp_half_hour = 1:1
	                if (bev_state == 0)             %If not plugged in
	                    %Set Priority to 0
	                    priority = 0;  
	                    %Set Laxity to Max
	                    t_laxity = 24;
	            
	                elseif(t_laxity < laxity_cutoff)         %If Laxity less than 1 hour: Charge
	                    %Set Priority to 100
	                    priority = 100;  

	                elseif(curr_SoC <= 1-charge_rate/batt_size)  % Not Chraging but available for DTU  
	                    %Set Priority to 0
	                    priority = 10;  
	                    %Set Laxity to Max
	                    t_laxity = 24;   
	                else                            %Else Vehicle Fully Charged 
	                    %Set Priority to 0
	                    priority = 0;  
	                end
	            end

	            %Charge Vehicles
	            for temp_half_hour = 1:1
	               cutoff_priority = 80;
	               current_vehicle(5, 1) = curr_SoC;
	               if ((DSR_hour <= hour) && (DSR_hour + DSR_duration >= hour)) % If within the DSR window
	                    if (DSR_direction == 0) %No DSR Service Called
	                        if (bev_state == 0) % Not Plugged In
	                            %State = Not Plugged in
	                            current_vehicle(6, 1) = 0;
	 
	                        elseif (priority < 10) %Do not Charge
	                            %State = Not Charging
	                            current_vehicle(6, 1) = 2;
	                            %Current SoC = Current SoC
	                            current_vehicle(5, 1) = current_vehicle(5, 1) + 0;

	                        elseif (priority >= cutoff_priority) %Above cutoff : Charge
	                            %State = Charging
	                            current_vehicle(6, 1) = 1;
	                            %Current SoC = Current SoC + hour of charge
	                            current_vehicle(5, 1) = current_vehicle(5, 1) + charge_rate/batt_size;

	                        else
	                            % Below cutoff for charge
	                            %State = Plugged in Not Charging
	                            current_vehicle(6, 1) = 2;
	                            %Current SoC = Current SoC;
	                            current_vehicle(5, 1) = current_vehicle(5, 1) + 0;
	                        end
	                    
	                    elseif (DSR_direction == 1) % Demand Turn Down - stop charging and reverse
	                        if (bev_state == 0) % Not Plugged In
	                            %State = Not Plugged in
	                            current_vehicle(6, 1) = 0;

	                        elseif (priority <= 0) %Too full to charge : Inject
	                            %State = Was Not Charging, Now Injecting
	                            current_vehicle(6, 1) = 4;
	                            %Current SoC = Current SoC - hour of charge
	                            current_vehicle(5, 1) = current_vehicle(5, 1) - charge_rate/batt_size;

	                        elseif (priority >= cutoff_priority) %Above cutoff, Should Charge : Injecting
	                            %State = Was Charging, Now Injecting
	                            current_vehicle(6, 1) = 3;
	                            %Current SoC = Current SoC - hour of charge
	                            current_vehicle(5, 1) = current_vehicle(5, 1) - charge_rate/batt_size;

	                        else % Below cutoff for charge : Injecting
	                            %State = Was Not Charging, Now Injecting
	                            current_vehicle(6, 1) = 4;
	                            %Current SoC = Current SoC - hour of charge
	                            current_vehicle(5, 1) = current_vehicle(5, 1) - charge_rate/batt_size;
	                        end

	                    elseif (DSR_direction == 2) % Demand Turn Up - start charging those waiting
	                        if (bev_state == 0) % Not Plugged In
	                            %State = Not Plugged in
	                            current_vehicle(6, 1) = 0;

	                        elseif (priority < 10) %Do not Charge - full battery
	                            %State = Not Charging
	                            current_vehicle(6, 1) = 2;
	                            %Current SoC = Current SoC
	                            current_vehicle(5, 1) = current_vehicle(5, 1) + 0;

	                        elseif (priority >= cutoff_priority) %Above cutoff : Charge like normal
	                            %State = Charging
	                            current_vehicle(6, 1) = 1;
	                            %Current SoC = Current SoC + hour of charge
	                            current_vehicle(5, 1) = current_vehicle(5, 1) + charge_rate/batt_size;

	                        else % Below cutoff for charge : Normally do not charge, now demand turn up
	                            %State = Demand turn Up
	                            current_vehicle(6, 1) = 6;
	                            %Current SoC = Current SoC + hour of charge
	                            current_vehicle(5, 1) = current_vehicle(5, 1) + charge_rate/batt_size;
	                        end
	                    
	                    end

	                else %Act as if normal because outside DSR window
	                    if (bev_state == 0) % Not Plugged In
	                        %State = Not Plugged in
	                        current_vehicle(6, 1) = 0;

	                    elseif (priority <= 0) %Do not Charge
	                        %State = Not Charging
	                        current_vehicle(6, 1) = 2;
	                        %Current SoC = Current SoC
	                        current_vehicle(5, 1) = current_vehicle(5, 1) + 0;

	                    elseif (priority >= cutoff_priority) %Above cutoff : Charge
	                        %State = Charging
	                        current_vehicle(6, 1) = 1;
	                        %Current SoC = Current SoC + hour of charge
	                        current_vehicle(5, 1) = current_vehicle(5, 1) + charge_rate/batt_size;

	                    else % Below cutoff for charge
	                        %State = Plugged in Not Charging
	                        current_vehicle(6, 1) = 2;
	                        %Current SoC = Current SoC;
	                        current_vehicle(5, 1) = current_vehicle(5, 1) + 0;
	                    end
	                end          
	            end  

	            % Remove results showing 0 SoC when EV disconnected  
	            if (current_vehicle(5, 1) == 0)
	                current_vehicle(5,1) = NaN;
	            end

	            % Record Vehicle Status
	            fleet_data(1:9, vehicle_num) = current_vehicle(1:9, 1);
	            FleetCharging(hour, vehicle_num) = fleet_data(6, vehicle_num);
	            fleet_SoC(hour, vehicle_num) = fleet_data(5, vehicle_num);
	            fleet_Priority(hour, vehicle_num) = priority;
	        end  
	               
	end

	%% Record Results for export
	for x_hour = 1:24  
		%Hour of Day
		temp_result(x_hour, 1) = x_hour-1;
		%Vehicles at Home
		temp_result(x_hour, 2) = fleet_Size - sum(FleetCharging(x_hour, :)==0);
		%Vehicles Charging
		temp_result(x_hour, 3) = sum(FleetCharging(x_hour, :) == 1);
		%Vehicles Not Charging
		temp_result(x_hour, 4) = sum(FleetCharging(x_hour, :) == 2);
	    %Vehicles was Charging - Now Injecting
	    temp_result(x_hour, 5) = sum(FleetCharging(x_hour, :) == 3);
	    %Vehicles was Not Charging - Now Injecting
	    temp_result(x_hour, 6) = sum(FleetCharging(x_hour, :) == 4);
	    %Vehicles was Charging - Now Charging
	    temp_result(x_hour, 7) = sum(FleetCharging(x_hour, :) == 5);
	    %Vehicles was Not Charging - Now Charging
	    temp_result(x_hour, 8) = sum(FleetCharging(x_hour, :) == 6);
	end	
	result = temp_result;

	%%  Display Results
	    for temp_hour = 1:24
	       plot_time(temp_hour, 1) = temp_hour-1;
	    end

		%% Plot random vehicles SoC to check algorithm
		vehicle1 = 006;
		vehicle2 = 007;
	    vehicle3 = 3006;
	    vehicle4 = 3008;
	    if (DSR_direction == 0)
	        s_DSR = string('No Service');
	    elseif (DSR_direction == 1)
	        s_DSR = string('Demand Turn Down');
	    elseif (DSR_direction == 2)
	        s_DSR = string('Demand Turn Up');
	    end
		figure
		plot(plot_time, fleet_SoC(:, vehicle1) , plot_time, fleet_SoC(:, vehicle2) , plot_time, fleet_SoC(:, vehicle3) , plot_time, fleet_SoC(:, vehicle4) )
		legend('Vehicle 1 ASAP','Vehicle 2 ASAP','Vehicle 3 ALAP', 'Vehicle 4 ALAP')
	    legend('Location','southeast')
	    axis([0 24 0 1]);
	    s_title = '{\bf\fontsize{14} Vehicle State of Charge under Demand Response Activation}';
	    s_subTitle = 'DSR Service: ' + s_DSR + ' Time:' + string(DSR_hour-1) + ':00 - ' + string(DSR_hour+DSR_duration-0.99) + ':00' ;
	    title( {s_title;s_subTitle},'FontWeight','Normal' )
	    xlabel('Time of Day (hr)') 
	    ylabel('Vehicle State of Charge') 
	    s_filename = 'V2G_Vehicle_SoC '+ s_DSR + ' ' + string(DSR_hour-1);
	    if save_img
	        print(s_filename ,'-dpng')
	    end
	    close


		% Plot Histogram of maximum SoC to check how many vehicles were not charged
	    Dep_Soc(1, fleet_Size) = 0;
	    for temp = 1:fleet_Size
	        temp2 = t_dep_hour(1,temp) - 1;
	        if (temp2 <= 0)
	            temp2 = temp2 + 24;
	        end
	        Dep_Soc(1, temp) = fleet_SoC(temp2, temp);
	    end
		figure;
		histogram(Dep_Soc)
	    s_title = '{\bf\fontsize{14} Fleet SoC Distribution under Demand Response Activation}';
	    s_subTitle = 'DSR Service: ' + s_DSR + ' Time:' + string(DSR_hour-1) + ':00 - ' + string(DSR_hour+DSR_duration-0.99) + ':00' ;
	    title( {s_title;s_subTitle},'FontWeight','Normal' ) 
	    ylabel('Vehicle State of Charge') 
	    axis([0 1 0 fleet_Size]);
	    s_filename = 'V2G_Fleet Soc Distribution '+ s_DSR + ' ' + string(DSR_hour-1);
	    if save_img
	        print(s_filename ,'-dpng')
	    end
	    close
	    hault = 1;
end

function result = V2G_Analyse(input_criteria)
	%% Simulation Details			
	%input_criteria = [DSR_duration, fleet_Size, ChargeRate, BatSize, StartSoC, Req_SoC, save_img]


	% result is returns 2:24 array
	% result(1, :) = Demand turn Down response for 24 hours
	% result(2, :) = Demand turn Up response for 24 hours
	%---------------------------------------------------------------------------------------

	DSR_hour = 1; %Will be changed in loop below
	DSR_duration = input_criteria(1,1);
	fleet_Size = input_criteria(1,2);
	ChargeRate = input_criteria(1,3);
	BatSize = input_criteria(1,4);
	StartSoC = input_criteria(1,5); 
	Req_SoC = input_criteria(1,6);
	save_img = input_criteria(1,7);

	%To address issues with indexing for hours starting 0:00 have used this for plotting results
	results_hours = linspace(0,23,24);

	%% Run Simulation for Demand Turn Down every hour of the day
	DSR_direction = 1;
	for x = 1:24
		DSR_hour = x;
		DSR_details = [DSR_hour, DSR_direction, DSR_duration, ChargeRate, fleet_Size, StartSoC, Req_SoC, BatSize];
		sim_results = V2G_Charge(DSR_details);

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
		sim_results = V2G_Charge(DSR_details);

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
		sim_results = V2G_Charge(DSR_details);

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
	s_title = '{\bf\fontsize{14} DSR Power vs Time of Day : Bi-Directional}';
	s_subTitle =  'Vehicle Fleet of ' + string(fleet_Size) + '  ' + string(ChargeRate) + 'kW EVs' ;
	title( {s_title;s_subTitle},'FontWeight','Normal')
	axis([0 24 0 20])
	xlabel('Time of Day (hr)') 
	ylabel('Power (MW)') 
	legend('Demand Turn Down', 'Demand Turn Up')		
	if save_img
		print('V2G Results' ,'-dpng')
	end
	close

	%% Save Results
	temp_result(1, :) = results_DTD;
	temp_result(2, :) = results_DTU;
	result = temp_result
end

%% ---------------------------------------------------------------------------------------
% 	Charging Methods
%---------------------------------------------------------------------------------------

function result = ChargingModel(fleet_def)
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


	%plot arrival and departure times histogram once
	Scenario{1,1} = [10000, 0.9 - 1/40 , 0.9, 40, 3];
	if (fleet_def == Scenario{1,1})
	    figure;
	    yyaxis right
	    histogram(fleet_data(1,:),'BinWidth',0.5)
	    hold on
	    histogram(fleet_data(2,:),'BinWidth',0.5)
	    hold off
	    hold on
	    yyaxis left
	    plot(fleet_ASAP(1:24, 1), fleet_ASAP(1:24, 6))
	    hold off
	    legend('Arrival', 'Departure', 'Vehicles at Home')
	    title('Arrival and Departure distribution of fleet')
	    xlabel('Hour of Day') 
	    ylabel('Number of Vehicles') 
	    print('Arrival and Departure Times','-dpng')
	    close
	    vehicles_at_home = fleet_ASAP(1:24, 6)/10000;
	end

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
	result = charging_result;
	%result = not_charging_result;
end

function void = Sensitivity_Analysis(void)
    % for x = 0: 23
    % hour(x+1, 1) = x;   
    % end

    %To address issues with indexing for hours starting 0:00 have used this for plotting results
	hour = linspace(0,23,24);

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
end



function fleet_state = Charge_ASAP(fleet_data)
	%% Setup Simulation
	FleetStatus(24, 6) = 0;
	test_vehicle(24, 9) = 0; 
	test_num = 3; %random vehicle number to check on


	%% Begin Iteration
	start_hour = 0; %testing using 1 will move to 13 or 15 when ready to process
	fleet_priorities(24,length(fleet_data)) = 0; 
	fleet_laxity(24,length(fleet_data)) = 0; 
	N_100_priority(23, 2) = 0;
	 for hour_x = 0:23
	     
	   %Adjust time to start at start hour and return to beginning of day
	   hour = hour_x + start_hour;
	   if (hour>23)
	        hour = hour - 24;
	   end
	     
	   %% Check vehicle locations
	   fleet_data = Vehicle_home(fleet_data, hour);

	   %% Calculate Priority 
	   for x = 1: length(fleet_data)
	     
	        %extract variables for vehicle
	        t_arr =  fleet_data(1, x);
	        t_dep = fleet_data(2, x);
	        start_SoC = fleet_data(3, x);
	        req_SoC = fleet_data(4, x);
	        curr_SoC = fleet_data(5, x);
	        bev_state = fleet_data(6, x);
	        batt_size = fleet_data(8, x);
	        charge_rate = fleet_data(9, x);
	        
	        if (((t_arr - hour) <= 0) && ((t_arr - hour) > -1 ))
	            %Vehicle Arriving in next hour - set Current SoC to arrival
	            curr_SoC = start_SoC;
	            fleet_data(5, x) = start_SoC;
	        end
	        
	        %Calculate time plugged in
	        t_plugged_in = hour-t_arr;
	        if (t_plugged_in<0)
	            t_plugged_in = t_plugged_in + 24;
	        end
	        
	        %Calculate time remaining
	        if ((t_dep< t_arr) && (t_dep < hour))
	         t_rem = t_dep-hour + 24;           
	        else
	         t_rem = t_dep-hour;                    
	        end
	        
	        %Calculate Laxity
	        t_charge = (req_SoC-curr_SoC)*batt_size/charge_rate;
	        t_laxity =  t_rem - t_charge ;
	        %if laxity is negative set to 0
	        if (t_laxity < 0)
	            
	            t_laxity = 0;
	        end

	        
	        curr_SoC = start_SoC + t_plugged_in*charge_rate/batt_size;
	        
	        if (bev_state == 0)             %If not plugged in
	            %Set Priority to 0
	            priority = 0;  
	            %Set Laxity to Max
	            t_laxity = 24;
	            
	        elseif(req_SoC <= curr_SoC)     % If Charged
	            %Set Priority to 0
	            priority = 0;  
	            %Set Laxity to Max
	            t_laxity = 24;
	        else                            %Charge Vehicle
	            %Set Priority to 100
	            priority = 100;          
	        end
	        
	        % Record Priority and Laxity for All Vehicles
	        fleet_priorities(hour+1, x) = priority;
	        fleet_laxity(hour+1, x) = t_laxity;

	    end
	    
	   %% Charge Vehicles
	   cutoff_priority = 80;
	   for x = 1: length(fleet_data)
	        priority = fleet_priorities(hour+1, x);
	        if (fleet_data(6, x) == 0) % Not Plugged In
	            %State = Not Plugged in
	            fleet_data(6, x) = 0;
	            
	        elseif (priority <= 0) %Do not Charge
	            %State = Not Charging
	            fleet_data(6, x) = 2;
	            %Current SoC = Current SoC + hour of charge
	            fleet_data(5, x) = fleet_data(5, x) + 0;
	        
	        elseif (priority == 100) %Immediate Charge
	            %State = Charging
	            fleet_data(6, x) = 1;
	            %Current SoC = Current SoC + hour of charge
	            fleet_data(5, x) = fleet_data(5, x) + charge_rate/batt_size;
	            
	        elseif (priority >= cutoff_priority) %Above cutoff : Charge
	            %State = Charging
	            fleet_data(6, x) = 1;
	            %Current SoC = Current SoC + hour of charge
	            fleet_data(5, x) = fleet_data(5, x) + charge_rate/batt_size;
	              
	        else
	            % Below cutoff for charge
	            %State = Plugged in Not Charging
	            fleet_data(6, x) = 2;
	            %Current SoC = Current SoC;
	            fleet_data(5, x) = fleet_data(5, x) + 0;

	        end
	    end    
	    
	   %% Record Stats
	   for x = 1
	    %Record test vehicle state
	        test_vehicle(hour+ 1, 1) = fleet_data(1, test_num);
	        test_vehicle(hour+ 1, 2) = fleet_data(2, test_num);
	        test_vehicle(hour+ 1, 3) = fleet_data(3, test_num);
	        test_vehicle(hour+ 1, 4) = fleet_data(4, test_num);
	        test_vehicle(hour+ 1, 5) = fleet_data(5, test_num);
	        test_vehicle(hour+ 1, 6) = fleet_data(6, test_num);
	        test_vehicle(hour+ 1, 7) = fleet_data(7, test_num);
	        test_vehicle(hour+ 1, 8) = fleet_data(8, test_num);
	        test_vehicle(hour+ 1, 9) = fleet_data(9, test_num);
	        test_vehicle(hour+ 1, 11) = priority;
	        test_vehicle(hour+ 1, 12) = fleet_laxity(hour+1, test_num);
	        
	    
	    %Record fleet state
	        FleetStatus(hour+ 1, 1)= hour;
	    %Count vehicles in different states 
	        % State 0 : Disconnected (not at home)
	        FleetStatus(hour+ 1, 2) = sum(fleet_data(6, :)==0);
	        % State 1 : Charging
	        FleetStatus(hour+ 1, 3) = sum(fleet_data(6, :)==1);
	        % State 2 : Not Charging
	        FleetStatus(hour+ 1, 4) = sum(fleet_data(6, :)==2);
	        % State -1 : Plugged in - not calculated
	        FleetStatus(hour+ 1, 5) = sum(fleet_data(6, :)==-1);
	        % All vehicles at home
	        FleetStatus(hour+ 1, 6) =   FleetStatus(hour+ 1, 3) +  FleetStatus(hour+ 1, 4) +  FleetStatus(hour+ 1, 5);
	    end
	        
	 end
	    %% Display and Return Results

	% figure;
	% plot(FleetStatus(1:24, 1), FleetStatus(1:24, 6),FleetStatus(1:24, 1), FleetStatus(1:24, 2),FleetStatus(1:24, 1), FleetStatus(1:24, 3), FleetStatus(1:24, 1), FleetStatus(1:24, 4))
	% title('Vehicles States for Charge ASAP')
	% xlabel('Hour of Day') 
	% ylabel('Number of vehicles') 
	% axis([0 23 0 max(FleetStatus(1:24, 6))*1.1])
	% legend('Vehciles at Home', 'Vehicles not at home', 'Vehicles Charging', 'Vehicles Not Charging')

	% figure;
	% plot(FleetStatus(1:24, 1), FleetStatus(1:24, 3), FleetStatus(1:24, 1), FleetStatus(1:24, 4))
	% title('Vehicles States for Charge ASAP Scheduling')
	% xlabel('Hour of Day') 
	% ylabel('Number of vehicles') 
	% axis([0 23 0 max(FleetStatus(1:24, 6))*1.1])
	% legend('Vehicles Charging', 'Vehicles Not Charging')

	% min_Power_DTD = min(FleetStatus(1:24, 3))*charge_rate
	% min_Power_DTU = min(FleetStatus(1:24, 4))*charge_rate

	% Return Status of Fleet
	fleet_state = FleetStatus;
end

function fleet_state = Charge_ALAP(fleet_data)
	%% Setup Simulation
	FleetStatus(24, 6) = 0;
	test_vehicle(24, 9) = 0; 
	test_num = 3; %random vehicle number to check on


	%% Begin Iteration
	start_hour = 0; %testing using 1 will move to 13 or 15 when ready to process
	fleet_priorities(24,length(fleet_data)) = 0; 
	fleet_laxity(24,length(fleet_data)) = 0; 
	N_100_priority(23, 2) = 0;
	 for hour_x = 0:23
	     
	   %Adjust time to start at start hour and return to beginning of day
	   hour = hour_x + start_hour;
	   if (hour>23)
	        hour = hour - 24;
	   end
	     
	   %% Check vehicle locations
	   fleet_data = Vehicle_home(fleet_data, hour);

	   %% Calculate Priority 
	   for x = 1: length(fleet_data)
	     
	        %extract variables for vehicle
	        t_arr =  fleet_data(1, x);
	        t_dep = fleet_data(2, x);
	        start_SoC = fleet_data(3, x);
	        req_SoC = fleet_data(4, x);
	        curr_SoC = fleet_data(5, x);
	        bev_state = fleet_data(6, x);
	        batt_size = fleet_data(8, x);
	        charge_rate = fleet_data(9, x);
	        
	        if (((t_arr - hour) <= 0) && ((t_arr - hour) > -1 ))
	            %Vehicle Arriving in next hour - set Current SoC to arrival
	            curr_SoC = start_SoC;
	            fleet_data(5, x) = start_SoC;
	        end
	        
	        %Calculate time plugged in
	        t_plugged_in = hour-t_arr;
	        if (t_plugged_in<0)
	            t_plugged_in = t_plugged_in + 24;
	        end
	        
	        %Calculate time remaining
	        if ((t_dep< t_arr) && (t_dep < hour))
	         t_rem = t_dep-hour + 24;           
	        else
	         t_rem = t_dep-hour;                    
	        end
	        
	        %Calculate Laxity
	% Calculated only using arrival SoC and time        t_charge = (req_SoC-curr_SoC)*batt_size/charge_rate;
	        t_charge = (req_SoC-start_SoC)*batt_size/charge_rate;
	        t_laxity =  t_rem - t_charge ;
	        %if laxity is negative set to 0
	        if (t_laxity < 0)
	            
	            t_laxity = 0;
	        end

	        
	        if (bev_state == 0)             %If not plugged in
	            %Set Priority to 0
	            priority = 0;  
	            %Set Laxity to Max
	            t_laxity = 24;
	            
	        elseif(t_laxity <= 0.15)         %If Laxity less than 1 hour: Charge
	            %Set Priority to 100
	            priority = 100;  
	        else                            %Else Charge Vehicle Later
	            %Set Priority to 0
	            priority = 0;  
	        end
	        
	        % Record Priority and Laxity for All Vehicles
	        fleet_priorities(hour+1, x) = priority;
	        fleet_laxity(hour+1, x) = t_laxity;

	    end
	    
	   %% Charge Vehicles
	   cutoff_priority = 80;
	   for x = 1: length(fleet_data)
	        priority = fleet_priorities(hour+1, x);
	        if (fleet_data(6, x) == 0) % Not Plugged In
	            %State = Not Plugged in
	            fleet_data(6, x) = 0;
	            
	        elseif (priority <= 0) %Do not Charge
	            %State = Not Charging
	            fleet_data(6, x) = 2;
	            %Current SoC = Current SoC + hour of charge
	            fleet_data(5, x) = fleet_data(5, x) + 0;
	        
	        elseif (priority == 100) %Immediate Charge
	            %State = Charging
	            fleet_data(6, x) = 1;
	            %Current SoC = Current SoC + hour of charge
	            fleet_data(5, x) = fleet_data(5, x) + charge_rate/batt_size;
	            
	        elseif (priority >= cutoff_priority) %Above cutoff : Charge
	            %State = Charging
	            fleet_data(6, x) = 1;
	            %Current SoC = Current SoC + hour of charge
	            fleet_data(5, x) = fleet_data(5, x) + charge_rate/batt_size;
	              
	        else
	            % Below cutoff for charge
	            %State = Plugged in Not Charging
	            fleet_data(6, x) = 2;
	            %Current SoC = Current SoC;
	            fleet_data(5, x) = fleet_data(5, x) + 0;

	        end
	    end    
	    
	   %% Record Stats
	   for x = 1
	    %Record test vehicle state
	        test_vehicle(hour+ 1, 1) = fleet_data(1, test_num);
	        test_vehicle(hour+ 1, 2) = fleet_data(2, test_num);
	        test_vehicle(hour+ 1, 3) = fleet_data(3, test_num);
	        test_vehicle(hour+ 1, 4) = fleet_data(4, test_num);
	        test_vehicle(hour+ 1, 5) = fleet_data(5, test_num);
	        test_vehicle(hour+ 1, 6) = fleet_data(6, test_num);
	        test_vehicle(hour+ 1, 7) = fleet_data(7, test_num);
	        test_vehicle(hour+ 1, 8) = fleet_data(8, test_num);
	        test_vehicle(hour+ 1, 9) = fleet_data(9, test_num);
	        test_vehicle(hour+ 1, 11) = priority;
	        test_vehicle(hour+ 1, 12) = fleet_laxity(hour+1, test_num);
	        
	    
	    %Record fleet state
	        FleetStatus(hour+ 1, 1)= hour;
	    %Count vehicles in different states 
	        % State 0 : Disconnected (not at home)
	        FleetStatus(hour+ 1, 2) = sum(fleet_data(6, :)==0);
	        % State 1 : Charging
	        FleetStatus(hour+ 1, 3) = sum(fleet_data(6, :)==1);
	        % State 2 : Not Charging
	        FleetStatus(hour+ 1, 4) = sum(fleet_data(6, :)==2);
	        % State -1 : Plugged in - not calculated
	        FleetStatus(hour+ 1, 5) = sum(fleet_data(6, :)==-1);
	        % All vehicles at home
	        FleetStatus(hour+ 1, 6) =   FleetStatus(hour+ 1, 3) +  FleetStatus(hour+ 1, 4) +  FleetStatus(hour+ 1, 5);
	    end
	        
	 end
	   %% Display and Return Results

	% figure;
	% plot(FleetStatus(1:24, 1), FleetStatus(1:24, 6),FleetStatus(1:24, 1), FleetStatus(1:24, 2),FleetStatus(1:24, 1), FleetStatus(1:24, 3), FleetStatus(1:24, 1), FleetStatus(1:24, 4))
	% title('Vehicles States for Charge ASAP')
	% xlabel('Hour of Day') 
	% ylabel('Number of vehicles') 
	% axis([0 23 0 max(FleetStatus(1:24, 6))*1.1])
	% legend('Vehciles at Home', 'Vehicles not at home', 'Vehicles Charging', 'Vehicles Not Charging')

	% figure;
	% plot(FleetStatus(1:24, 1), FleetStatus(1:24, 3), FleetStatus(1:24, 1), FleetStatus(1:24, 4))
	% title('Vehicles States for Charge ASAP Scheduling')
	% xlabel('Hour of Day') 
	% ylabel('Number of vehicles') 
	% axis([0 23 0 max(FleetStatus(1:24, 6))*1.1])
	% legend('Vehicles Charging', 'Vehicles Not Charging')

	% min_Power_DTD = min(FleetStatus(1:24, 3))*charge_rate
	% min_Power_DTU = min(FleetStatus(1:24, 4))*charge_rate

	% Return Status of Fleet
	fleet_state = FleetStatus;
end

function fleet_state = Charge_MidP(fleet_data)
	%% Setup Simulation
	FleetStatus(24, 6) = 0;
	test_vehicle(24, 9) = 0; 
	test_num = 3; %random vehicle number to check on


	%% Begin Iteration
	start_hour = 0; %testing using 1 will move to 13 or 15 when ready to process
	fleet_priorities(24,length(fleet_data)) = 0; 
	fleet_laxity(24,length(fleet_data)) = 0; 
	N_100_priority(23, 2) = 0;
	 for hour_x = 0:23
	     
	   %Adjust time to start at start hour and return to beginning of day
	   hour = hour_x + start_hour;
	   if (hour>23)
	        hour = hour - 24;
	   end
	     
	   %% Check vehicle locations
	   fleet_data = Vehicle_home(fleet_data, hour);

	   %% Calculate Priority ASAP
	   for x = 1 : length(fleet_data)/2
	     
	        %extract variables for vehicle
	        t_arr =  fleet_data(1, x);
	        t_dep = fleet_data(2, x);
	        start_SoC = fleet_data(3, x);
	        req_SoC = fleet_data(4, x);
	        curr_SoC = fleet_data(5, x);
	        bev_state = fleet_data(6, x);
	        batt_size = fleet_data(8, x);
	        charge_rate = fleet_data(9, x);
	        
	        if (((t_arr - hour) <= 0) && ((t_arr - hour) > -1 ))
	            %Vehicle Arriving in next hour - set Current SoC to arrival
	            curr_SoC = start_SoC;
	            fleet_data(5, x) = start_SoC;
	        end
	        
	        %Calculate time plugged in
	        t_plugged_in = hour-t_arr;
	        if (t_plugged_in<0)
	            t_plugged_in = t_plugged_in + 24;
	        end
	        
	        %Calculate time remaining
	        if ((t_dep< t_arr) && (t_dep < hour))
	         t_rem = t_dep-hour + 24;           
	        else
	         t_rem = t_dep-hour;                    
	        end
	        
	        %Calculate Laxity
	        t_charge = (req_SoC-curr_SoC)*batt_size/charge_rate;
	        t_laxity =  t_rem - t_charge ;
	        %if laxity is negative set to 0
	        if (t_laxity < 0)
	            
	            t_laxity = 0;
	        end

	        
	        curr_SoC = start_SoC + t_plugged_in*charge_rate/batt_size;
	        
	        if (bev_state == 0)             %If not plugged in
	            %Set Priority to 0
	            priority = 0;  
	            %Set Laxity to Max
	            t_laxity = 24;
	            
	        elseif(req_SoC <= curr_SoC)     % If Charged
	            %Set Priority to 0
	            priority = 0;  
	            %Set Laxity to Max
	            t_laxity = 24;
	        else                            %Charge Vehicle
	            %Set Priority to 100
	            priority = 100;          
	        end
	        
	        % Record Priority and Laxity for All Vehicles
	        fleet_priorities(hour+1, x) = priority;
	        fleet_laxity(hour+1, x) = t_laxity;

	   end
	   
	   %% Calculate Priority ALAP
	   for x = length(fleet_data)/2 : length(fleet_data)
	     
	        %extract variables for vehicle
	        t_arr =  fleet_data(1, x);
	        t_dep = fleet_data(2, x);
	        start_SoC = fleet_data(3, x);
	        req_SoC = fleet_data(4, x);
	        curr_SoC = fleet_data(5, x);
	        bev_state = fleet_data(6, x);
	        batt_size = fleet_data(8, x);
	        charge_rate = fleet_data(9, x);
	        
	        if (((t_arr - hour) <= 0) && ((t_arr - hour) > -1 ))
	            %Vehicle Arriving in next hour - set Current SoC to arrival
	            curr_SoC = start_SoC;
	            fleet_data(5, x) = start_SoC;
	        end
	        
	        %Calculate time plugged in
	        t_plugged_in = hour-t_arr;
	        if (t_plugged_in<0)
	            t_plugged_in = t_plugged_in + 24;
	        end
	        
	        %Calculate time remaining
	        if ((t_dep< t_arr) && (t_dep < hour))
	         t_rem = t_dep-hour + 24;           
	        else
	         t_rem = t_dep-hour;                    
	        end
	        
	        %Calculate Laxity
	% Calculated only using arrival SoC and time        t_charge = (req_SoC-curr_SoC)*batt_size/charge_rate;
	        t_charge = (req_SoC-start_SoC)*batt_size/charge_rate;
	        t_laxity =  t_rem - t_charge ;
	        %if laxity is negative set to 0
	        if (t_laxity < 0)
	            
	            t_laxity = 0;
	        end

	        
	        if (bev_state == 0)             %If not plugged in
	            %Set Priority to 0
	            priority = 0;  
	            %Set Laxity to Max
	            t_laxity = 24;
	            
	        elseif(t_laxity <= 0.15)         %If Laxity less than 1 hour: Charge
	            %Set Priority to 100
	            priority = 100;  
	        else                            %Else Charge Vehicle Later
	            %Set Priority to 0
	            priority = 0;  
	        end
	        
	        % Record Priority and Laxity for All Vehicles
	        fleet_priorities(hour+1, x) = priority;
	        fleet_laxity(hour+1, x) = t_laxity;

	   end
	  
	   %% Charge Vehicles
	   cutoff_priority = 80;
	   for x = 1: length(fleet_data)
	        priority = fleet_priorities(hour+1, x);
	        if (fleet_data(6, x) == 0) % Not Plugged In
	            %State = Not Plugged in
	            fleet_data(6, x) = 0;
	            
	        elseif (priority <= 0) %Do not Charge
	            %State = Not Charging
	            fleet_data(6, x) = 2;
	            %Current SoC = Current SoC + hour of charge
	            fleet_data(5, x) = fleet_data(5, x) + 0;
	        
	        elseif (priority == 100) %Immediate Charge
	            %State = Charging
	            fleet_data(6, x) = 1;
	            %Current SoC = Current SoC + hour of charge
	            fleet_data(5, x) = fleet_data(5, x) + charge_rate/batt_size;
	            
	        elseif (priority >= cutoff_priority) %Above cutoff : Charge
	            %State = Charging
	            fleet_data(6, x) = 1;
	            %Current SoC = Current SoC + hour of charge
	            fleet_data(5, x) = fleet_data(5, x) + charge_rate/batt_size;
	              
	        else
	            % Below cutoff for charge
	            %State = Plugged in Not Charging
	            fleet_data(6, x) = 2;
	            %Current SoC = Current SoC;
	            fleet_data(5, x) = fleet_data(5, x) + 0;

	        end
	    end    
	    
	   %% Record Stats
	   for x = 1
	    %Record test vehicle state
	        test_vehicle(hour+ 1, 1) = fleet_data(1, test_num);
	        test_vehicle(hour+ 1, 2) = fleet_data(2, test_num);
	        test_vehicle(hour+ 1, 3) = fleet_data(3, test_num);
	        test_vehicle(hour+ 1, 4) = fleet_data(4, test_num);
	        test_vehicle(hour+ 1, 5) = fleet_data(5, test_num);
	        test_vehicle(hour+ 1, 6) = fleet_data(6, test_num);
	        test_vehicle(hour+ 1, 7) = fleet_data(7, test_num);
	        test_vehicle(hour+ 1, 8) = fleet_data(8, test_num);
	        test_vehicle(hour+ 1, 9) = fleet_data(9, test_num);
	        test_vehicle(hour+ 1, 11) = priority;
	        test_vehicle(hour+ 1, 12) = fleet_laxity(hour+1, test_num);
	        
	    
	    %Record fleet state
	        FleetStatus(hour+ 1, 1)= hour;
	    %Count vehicles in different states 
	        % State 0 : Disconnected (not at home)
	        FleetStatus(hour+ 1, 2) = sum(fleet_data(6, :)==0);
	        % State 1 : Charging
	        FleetStatus(hour+ 1, 3) = sum(fleet_data(6, :)==1);
	        % State 2 : Not Charging
	        FleetStatus(hour+ 1, 4) = sum(fleet_data(6, :)==2);
	        % State -1 : Plugged in - not calculated
	        FleetStatus(hour+ 1, 5) = sum(fleet_data(6, :)==-1);
	        % All vehicles at home
	        FleetStatus(hour+ 1, 6) =   FleetStatus(hour+ 1, 3) +  FleetStatus(hour+ 1, 4) +  FleetStatus(hour+ 1, 5);
	    end
	        
	 end
	    %% Display and Return Results

	% figure;
	% plot(FleetStatus(1:24, 1), FleetStatus(1:24, 6),FleetStatus(1:24, 1), FleetStatus(1:24, 2),FleetStatus(1:24, 1), FleetStatus(1:24, 3), FleetStatus(1:24, 1), FleetStatus(1:24, 4))
	% title('Vehicles States for Charge ASAP')
	% xlabel('Hour of Day') 
	% ylabel('Number of vehicles') 
	% axis([0 23 0 max(FleetStatus(1:24, 6))*1.1])
	% legend('Vehciles at Home', 'Vehicles not at home', 'Vehicles Charging', 'Vehicles Not Charging')

	% figure;
	% plot(FleetStatus(1:24, 1), FleetStatus(1:24, 3), FleetStatus(1:24, 1), FleetStatus(1:24, 4))
	% title('Vehicles States for Charge ASAP Scheduling')
	% xlabel('Hour of Day') 
	% ylabel('Number of vehicles') 
	% axis([0 23 0 max(FleetStatus(1:24, 6))*1.1])
	% legend('Vehicles Charging', 'Vehicles Not Charging')

	% min_Power_DTD = min(FleetStatus(1:24, 3))*charge_rate
	% min_Power_DTU = min(FleetStatus(1:24, 4))*charge_rate

	% Return Status of Fleet
	fleet_state = FleetStatus;
end

function new_fleet_data = Vehicle_home(fleet_data, time)
	%% Vehicle Home 
	%{
	This function calculates whether a vehicle is at home or not
	or the hour following the time value given in the input
	The functions takes in a fleet dataset and calculates the state
	variable for each vehicle in the fleet for that hour time period
	before returning the new fleet data set to the origin with the state:
	0 = Away from Home
	-1 = At home, awaiting further calculation

	Complete as of 26 March 2018
	%}
	    for x = 1: length(fleet_data)
	       % check vehicle is home 
	       t_arr = fleet_data(1,x);
	       t_dep = fleet_data(2,x);

	       if ((t_arr <= time)  &&  (time <= t_dep))
	           %if( home ) then state = -1
	           fleet_data(6,x) = -1; 

	       elseif(  (t_dep < t_arr) && (time > t_arr)  )
	           fleet_data(6,x) = -1; 

	       elseif(  (t_dep < t_arr) && (time < t_dep)  )
	           fleet_data(6,x) = -1; 

	       else %else give state = 0
	           fleet_data(6,x) = 0; 
	           
	       end
	     
	       %if vehicle has recently arrived then set SoC to arrival SoC
	       
	       
	    end



	new_fleet_data = fleet_data;
end
