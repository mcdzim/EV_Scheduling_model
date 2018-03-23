function new_fleet_data = Vehicle_home(fleet_data, time)

    for x = 1: length(fleet_data)
       % check vehicle is home or give priority = 0
       t_arr = fleet_data(2,x);
       t_dep = fleet_data(3,x);

       if (  (t_arr < time) && (t_dep > time)  )
           fleet_data(6,x) = -1; 

       elseif(  (t_dep < t_arr) && (time > t_arr)  )
           fleet_data(6,x) = -1; 

       elseif(  (t_dep < t_arr) && (time < t_dep)  )
           fleet_data(6,x) = -1; 

       else
           fleet_data(6,x) = 0; 
           
       end

    end



new_fleet_data = fleet_data;

end
