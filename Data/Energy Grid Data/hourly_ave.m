function hourly_ave(data_value, data_timestamp, str_Title, str_X, str_Y, length_data)

LengthData = length_data; % test with first 1000 entries only

data_hour = hour(data_timestamp(1:LengthData, 1))+1;  % add one to shift time from 1-24 not 0-23
data = data_value(1:LengthData, 1);

data2 = zeros(24, LengthData);
for x= 1:LengthData
data2(data_hour(x, 1), x) = data(x, 1);  
Percent_complete = x/LengthData*100  %put this in to work out how much longer it needs to run
end

data2(data2 == 0) = NaN; %remove 0 values for NaNs

data3 = zeros(25, 1);
for x= 1:25
data3(1, x) = mean(data2(1:LengthData, x), 'omitnan' );      
end

%plot the data vs hour of day
figure;
plot(data3);
title(str_Title)
xlabel(str_X)
ylabel(str_Y)
% legend('aX', 'aY', 'aZ', 'aX filtered', 'aY filtered', 'aZ filtered')

end
