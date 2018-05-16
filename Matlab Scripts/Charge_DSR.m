function result = Charge_DSR(DSR_specs)
%% Simulation Details
% DSR_hour is the hour the service is called upon
% DSR_direction is the service required: 0= no service, 1= turn down,
% 2=turn up


% DSR_hour = 13;
% DSR_direction = 1;
% DSR_duration = 1;

DSR_hour = DSR_specs(1,1);
DSR_direction = DSR_specs(1,2);
DSR_duration = DSR_specs(1,3);

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
                else 													% If Fully Charged but available for DTU  
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

	                    elseif (priority <= 0) %Do not Charge
	                        %State = Not Charging
	                        current_vehicle(6, 1) = 2;
	                        %Current SoC = Current SoC + hour of charge
	                        current_vehicle(5, 1) = current_vehicle(5, 1) + 0;

	                    elseif (priority >= cutoff_priority) %Above cutoff : Should Charge
	                        %State = DTD
	                        current_vehicle(6, 1) = 3;
	                        %Current SoC = Current SoC
	                        current_vehicle(5, 1) = current_vehicle(5, 1) + 0;

	                    else
	                        % Below cutoff for charge
	                        %State = Plugged in Not Charging
	                        current_vehicle(6, 1) = 2;
	                        %Current SoC = Current SoC;
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
	                        current_vehicle(6, 1) = 4;
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
                else 													% If Fully Charged but available for DTU  
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

	                    elseif (priority <= 0) %Do not Charge
	                        %State = Not Charging
	                        current_vehicle(6, 1) = 2;
	                        %Current SoC = Current SoC + hour of charge
	                        current_vehicle(5, 1) = current_vehicle(5, 1) + 0;

	                    elseif (priority >= cutoff_priority) %Above cutoff : Should Charge
	                        %State = DTD
	                        current_vehicle(6, 1) = 3;
	                        %Current SoC = Current SoC
	                        current_vehicle(5, 1) = current_vehicle(5, 1) + 0;

	                    else
	                        % Below cutoff for charge
	                        %State = Plugged in Not Charging
	                        current_vehicle(6, 1) = 2;
	                        %Current SoC = Current SoC;
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
	                        current_vehicle(6, 1) = 4;
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
                t_laxity =  t_rem - t_charge ;
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
            
       			elseif(t_laxity <= 0.15)         %If Laxity less than 1 hour: Charge
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
	                        %Current SoC = Current SoC + hour of charge
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
	            	elseif (DSR_direction == 1) % Demand Turn Down
	                    if (bev_state == 0) % Not Plugged In
	                        %State = Not Plugged in
	                        current_vehicle(6, 1) = 0;

	                    elseif (priority <= 0) %Do not Charge
	                        %State = Not Charging
	                        current_vehicle(6, 1) = 2;
	                        %Current SoC = Current SoC + hour of charge
	                        current_vehicle(5, 1) = current_vehicle(5, 1) + 0;

	                    elseif (priority >= cutoff_priority) %Above cutoff : Should Charge
	                        %State = DTD
	                        current_vehicle(6, 1) = 3;
	                        %Current SoC = Current SoC
	                        current_vehicle(5, 1) = current_vehicle(5, 1) + 0;

	                    else
	                        % Below cutoff for charge
	                        %State = Plugged in Not Charging
	                        current_vehicle(6, 1) = 2;
	                        %Current SoC = Current SoC;
	                        current_vehicle(5, 1) = current_vehicle(5, 1) + 0;
	                    end

	            	elseif (DSR_direction == 2) % Demand Turn Up
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

	                    else
	                        % Below cutoff for charge
	                        %State = Plugged in Not Charging
	                        current_vehicle(6, 1) = 4;
	                        %Current SoC = Current SoC + hour of charge
	                        current_vehicle(5, 1) = current_vehicle(5, 1) + charge_rate/batt_size;
	                    end
					end
                else
                    if (bev_state == 0) % Not Plugged In
                        %State = Not Plugged in
                        current_vehicle(6, 1) = 0;

                    elseif (priority <= 0) %Do not Charge
                        %State = Not Charging
                        current_vehicle(6, 1) = 2;
                        %Current SoC = Current SoC + hour of charge
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
                end

                	
                	
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
            	if (bev_state == 0)             %If not plugged in
	            	%Set Priority to 0
	            	priority = 0;  
	            	%Set Laxity to Max
	            	t_laxity = 24;
            
       			elseif(t_laxity <= 0.15)         %If Laxity less than 1 hour: Charge
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
	                        %Current SoC = Current SoC + hour of charge
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
	            	elseif (DSR_direction == 1) % Demand Turn Down
	                    if (bev_state == 0) % Not Plugged In
	                        %State = Not Plugged in
	                        current_vehicle(6, 1) = 0;

	                    elseif (priority <= 0) %Do not Charge
	                        %State = Not Charging
	                        current_vehicle(6, 1) = 2;
	                        %Current SoC = Current SoC + hour of charge
	                        current_vehicle(5, 1) = current_vehicle(5, 1) + 0;

	                    elseif (priority >= cutoff_priority) %Above cutoff : Should Charge
	                        %State = DTD
	                        current_vehicle(6, 1) = 3;
	                        %Current SoC = Current SoC
	                        current_vehicle(5, 1) = current_vehicle(5, 1) + 0;

	                    else
	                        % Below cutoff for charge
	                        %State = Plugged in Not Charging
	                        current_vehicle(6, 1) = 2;
	                        %Current SoC = Current SoC;
	                        current_vehicle(5, 1) = current_vehicle(5, 1) + 0;
	                    end

	            	elseif (DSR_direction == 2) % Demand Turn Up
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

	                    else
	                        % Below cutoff for charge
	                        %State = Plugged in Not Charging
	                        current_vehicle(6, 1) = 4;
	                        %Current SoC = Current SoC + hour of charge
	                        current_vehicle(5, 1) = current_vehicle(5, 1) + charge_rate/batt_size;
	                    end
					end
                else
                    if (bev_state == 0) % Not Plugged In
                        %State = Not Plugged in
                        current_vehicle(6, 1) = 0;

                    elseif (priority <= 0) %Do not Charge
                        %State = Not Charging
                        current_vehicle(6, 1) = 2;
                        %Current SoC = Current SoC + hour of charge
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
                end

                	
                	
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
	%Vehicles Charging - Now Demand Turn Down
	temp_result(x_hour, 5) = sum(FleetCharging(x_hour, :) == 3);
	%Vehicles Not Charging - Now Demand Turn Up
	temp_result(x_hour, 6) = sum(FleetCharging(x_hour, :) == 4);
end	
result = temp_result;

%% Display Results - Commented out when using as a modular function
	%Plot Fleet Activities per hour of day
    for temp_hour = 1:24

       plot_data1(temp_hour, 1) = fleet_Size - sum(FleetCharging(temp_hour, :)==0); 
       plot_data2(temp_hour, 1) = sum(FleetCharging(temp_hour, :)==1); 
       plot_data3(temp_hour, 1) = sum(FleetCharging(temp_hour, :)==2); 
       plot_time(temp_hour, 1) = temp_hour-1;

       temp_half_hour = 2* temp_hour - 1;
       plot_data4(temp_half_hour, 1) = sum(FleetCharging(temp_hour, :)==3); 
       plot_data5(temp_half_hour, 1) = sum(FleetCharging(temp_hour, :)==4); 
       plot_time2(temp_half_hour, 1) = temp_hour-0.99;
       
       temp_half_hour = 2* temp_hour;
       plot_data4(temp_half_hour, 1) = sum(FleetCharging(temp_hour, :)==3); 
       plot_data5(temp_half_hour, 1) = sum(FleetCharging(temp_hour, :)==4); 
       plot_time2(temp_half_hour, 1) = temp_hour-.001;
       
    end


	% figure
	% plot(plot_time, plot_data1, plot_time, plot_data2, plot_time, plot_data3, plot_time, plot_data4, plot_time, plot_data5)
	% legend('Vehicles at Home', 'Charging', 'Not Charging', 'Demand Turn Down', 'Demand Turn Up')
	
	% %Plot Power Requirements
	% figure
	% plot(plot_time, plot_data2*ChargeRate/1000, plot_time, plot_data3*ChargeRate/1000) 
	% hold on
	% % Create area
	% area(plot_time2,plot_data4*ChargeRate/1000,'DisplayName','plot_data4','LineWidth',0.1);
	% area(plot_time2,plot_data5*ChargeRate/1000,'DisplayName','plot_data5','LineWidth',0.1);


	% %plot_time, plot_data4*ChargeRate/1000, plot_time, plot_data5*ChargeRate/1000)
	% legend('Vehicles Charging', 'Not Charging', 'Demand Turn Down', 'Demand Turn Up')
	% s_title = '{\bf\fontsize{14} Power usage of Vehicle Fleet under Demand Response Call}';
	% if(DSR_direction == 1)
	% 	s_subTitle = 'DSR Service: Demand Turn Down, Time:' + string(DSR_hour) + ':00 - ' + string(DSR_hour+DSR_duration+0.01) + ':00' ;
	% elseif(DSR_direction == 2)
	% 	s_subTitle = 'DSR Service: Demand Turn Down, Time:' + string(DSR_hour) + ':00 - ' + string(DSR_hour+DSR_duration+0.01) + ':00' ;
	% else(DSR_direction == 0)
	% 	s_subTitle = 'DSR Service: No Service' ;
	% end
	% title( {s_title;s_subTitle},'FontWeight','Normal' )
	% xlabel('Time of Day (hr)') 
	% ylabel('Power (MW)') 
 
	% % Plot random vehicles SoC to check algorithm
	% vehicle1 = 3006;
	% vehicle2 = 3007;
	% vehicle3 = 3008;
	% figure
	% plot(plot_time, fleet_SoC(:, vehicle1) , plot_time, fleet_SoC(:, vehicle2) , plot_time, fleet_SoC(:, vehicle3) )
	% legend('Vehicle 1','Vehicle 2','Vehicle 3')

	% % Plot random vehicles Priorities to check algorithm
	% figure
	% plot(plot_time, fleet_Priority(:, vehicle1) , plot_time, fleet_Priority(:, vehicle2) , plot_time, fleet_Priority(:, vehicle3) )
	% legend('Vehicle 1','Vehicle 2','Vehicle 3')

	% % Plot Histogram of maximum SoC to check how many vehicles were not charged
	% max_SoC(1, fleet_Size) = 0;
	% for temp_half_hour = 1: fleet_Size
	% 	max_SoC(1,temp_half_hour) = max(fleet_SoC(:, temp_half_hour))*100;
	% end
	% figure;
	% histogram(max_SoC(1,:))
	% title('Distribution of Vehicle State of Charge on Departure')
	% xlabel('Departure SoC') 
	% ylabel('Number of Vehicles') 


end
