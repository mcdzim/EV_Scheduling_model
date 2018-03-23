function new_fleet_data = Vehicle_home(fleet_data, time)

for x = 1: length(fleet_data)
   % check vehicle is home or give priority = 0
   if (fleet_data(1, x) > time)
       fleet_data(6, x) = 0;    
   elseif(fleet_data(2, x) < time)
       fleet_data(6, x) = 0;    
   else
        fleet_data(6, x) = -1;      
       %calculate time left to charge
       %calculate remaining time required to charge
       %calculate laxity
       %calculate waiting time
       
   end
       
    
end



new_fleet_data = fleet_data;

end
