function new_fleet_data = Charge_ASAP(fleet_data, time)

       
for x = 1: length(fleet_data)
    t_arr =  fleet_data(1, x);
    t_dep = fleet_data(2, x);
    charge_rate = fleet_data(9, x);
    req_SoC = fleet_data(4, x);
    curr_SoC = fleet_data(5, x);
    batt_size = fleet_data(8, x);
    if (fleet_data(6, x) == -1) %If plugged in
        if (curr_SoC < req_SoC) %If needing to charge

            %Set Status to charging
            fleet_data(6, x) = 1;

            %Fill battery by 1hr charge
            fleet_data(5, x) = fleet_data(5, x) + charge_rate/batt_size;
        else
            %Set Status to not charging
            fleet_data(6, x) = 2;            
        end
    end
end



new_fleet_data = fleet_data;

end
