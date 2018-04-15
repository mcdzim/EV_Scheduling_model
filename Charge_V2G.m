function result = Charge_V2G(DSR_specs)
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
    s_filename = 'Vehicle_SoC '+ s_DSR + ' ' + string(DSR_hour-1);
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
    s_filename = 'Fleet Soc Distribution '+ s_DSR + ' ' + string(DSR_hour-1);
    if save_img
        print(s_filename ,'-dpng')
    end
    close
    hault = 1;
end
