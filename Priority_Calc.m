function new_fleet_data = Priority_Calc(fleet_data, time)

for x = 1: length(fleet_data)
   %check if vehicle is at home
   if (fleet_data(x, 6) ~= 0)

       %calculate time left to charge
       time_remaining = time - fleet_data(x, 2);

       %calculate remaining time required to charge

       %calculate laxity
       %calculate waiting time
       fleet_data(x, 5) = 5;
       
   else   % set priority to 0 as vehicle is not present
       fleet_data(x, 5) = 5;       
   end
end



new_fleet_data = fleet_data;

end
