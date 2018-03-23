function new_fleet_data = Priority_Calc(fleet_data, time)

for x = 1: length(fleet_data)
    
   t_arr =  fleet_data(1, x);
   t_dep = fleet_data(2, x);
   if (t_dep<t_arr)
       t_dep = t_dep + 24;
   end

   
   
   charge_rate = fleet_data(9, x);
   req_SoC = fleet_data(4, x);
   curr_SoC = fleet_data(5, x);
   batt_size = fleet_data(8, x);
   
   %check if vehicle is at home
   if (fleet_data(6, x) == 0)
       % set priority to 0 as vehicle is not present
       priority = 0;         
   else

       if time > 15
           
       end
       %calculate time left to charge
       t_remaining =  t_dep - time;

       %calculate remaining time required to charge
       t_required  =  batt_size/charge_rate * (req_SoC - curr_SoC)/60; 
       
       %calculate laxity
       laxity = t_remaining - t_required;
       
 
       if (laxity < 0.5)
          priority = 100; 
       else
           
          priority = laxity; 
           
       end
       
       
     
   end
   
   fleet_data(5, x) = priority;
end



new_fleet_data = fleet_data;

end
