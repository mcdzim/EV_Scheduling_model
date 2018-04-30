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
