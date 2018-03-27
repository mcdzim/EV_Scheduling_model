function fleet_state = Priority_Calc(fleet_data)
%% Setup Simulation
FleetStatus(24, 6) = 0;
test_vehicle(24, 9) = 0; 
test_num = 200; %random vehicle number to check on

%Algorithm Variables
bias_SoC = 1;
bias_TimeRem = 1;
bias_TimeAvailable = 1;


%% Begin Iteration
start_hour = 1; %testing using 1 will move to 13 or 15 when ready to process
for hour = start_hour:23
   % check vehicle locations
   fleet_data = Vehicle_home(fleet_data, hour);
  
  
    
   
   %% Calculate Priority
    for x = 1: length(fleet_data)
        
        % extract variables for vehicle
        t_arr =  fleet_data(1, x);
        t_dep = fleet_data(2, x);
        start_SoC = fleet_data(3, x);
        req_SoC = fleet_data(4, x);
        curr_SoC = fleet_data(5, x);
        bev_state = fleet_data(6, x);
        batt_size = fleet_data(8, x);
        charge_rate = fleet_data(9, x);
        
        if (hour-t_arr < 1)
            curr_SoC = start_SoC;
        end
        
        
        
        %Calculate Laxity
        if ((t_dep< t_arr) && (t_dep < hour))
         t_rem = t_dep-hour + 24;           
        else
         t_rem = t_dep-hour;                    
        end

        t_charge = (req_SoC-start_SoC)*batt_size/charge_rate;

        t_laxity = t_charge - t_rem;
        

        if (bev_state == 0)%If not plugged in
            %Set Priority to 0
            priority = 0;            
        else
            
            %Calculate charge priority
            
            if curr_SoC < 40 %if SoC is less than 30, priority 100
                priority = 100;
            elseif (t_laxity < 0.5 && t_rem > 0 )%if less than 30 min laxity, priority 100
                priority = 100;
            else
                priority = 75;
            end      
            
             
            fleet_data(6, x) = priority;           
        end






   
    %% Rank Vehicles
    
    
    
    %% Charge Vehicles
        % Set cutoff priority to only allow top 15% of vehicles
        cutoff_p = 80;
    
        if (priority == 0) % Not Plugged In
            %State = Not Plugged in
            fleet_data(6, x) = 0;
            %Current SoC = 0
            fleet_data(5, x) = 0;
            
        elseif (priority == 100) % Immediate Charge
            %State = Charging
            fleet_data(6, x) = 1;
            %Current SoC = Current SoC + hour of charge
            fleet_data(5, x) = curr_SoC + charge_rate/batt_size;
            
        elseif (priority > cutoff_p) % Above cutoff for charge
            %State = Charging
            fleet_data(6, x) = 1;
            %Current SoC = Current SoC + hour of charge
            fleet_data(5, x) = curr_SoC + charge_rate/batt_size;

        else % Below cutoff for charge
            %State = Plugged in Not Charging
            fleet_data(6, x) = 2;
            %Current SoC = Current SoC;
            fleet_data(5, x) = curr_SoC;

        end
    end    
    
    %% Record Stats
    
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

for hour = 0:start_hour-1
    %copy same as above
end

% figure1 = figure;
% plot(FleetStatus(1:24, 1), FleetStatus(1:24, 6),FleetStatus(1:24, 1), FleetStatus(1:24, 2),FleetStatus(1:24, 1), FleetStatus(1:24, 3), FleetStatus(1:24, 1), FleetStatus(1:24, 4))
% title('Vehicles States for Charge ASAP')
% xlabel('Hour of Day') 
% ylabel('Number of vehicles') 
% axis([0 23 0 max(FleetStatus(1:24, 6))*1.1])
% legend('Vehciles at Home', 'Vehicles not at home', 'Vehicles Charging', 'Vehicles Not Charging')

figure1 = figure;
plot(FleetStatus(1:24, 1), FleetStatus(1:24, 3), FleetStatus(1:24, 1), FleetStatus(1:24, 4))
title('Vehicles States for Charge Priority Scheduling')
xlabel('Hour of Day') 
ylabel('Number of vehicles') 
axis([0 23 0 max(FleetStatus(1:24, 6))*1.1])
legend('Vehicles Charging', 'Vehicles Not Charging')

% min_Power_DTD = min(FleetStatus(1:24, 3))*charge_rate
% min_Power_DTU = min(FleetStatus(1:24, 4))*charge_rate

% Return Status of Fleet
fleet_state = FleetStatus;
 

end

