clear;
load2;  % CSV format: id, timestamp, demand, frequency, coal, nuclear, ccgt, wind, pumped, hydro, biomass, oil, solar, ocgt, french_ict, dutch_ict, irish_ict, ew_ict, other, north_south, scotland_england

hourly_ave(demand, timestamp, 'Demand vs Time of Day', 'Time of day (h)', 'UK Demand (GW)', length(timestamp))
%hourly_ave(demand/1000, timestamp, 'Demand vs Time of Day', 'Time of day (h)', 'UK Demand (GW)', 5000)
