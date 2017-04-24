clc
clear
%% Opening and reading the Nome AK data %%

%Open the NetCDF file%
ncid = netcdf.open('Nome-HOS-FedVab@2013-09-01T000000Z@P1M@PT200F@V0.nc', 'NC_NOWRITE');
time = netcdf.getVar(ncid,0);
power = netcdf.getVar(ncid,1);
Power = [time, power];
%plot(time,power)  %plot the value (what is mentioned in the file name) against the index
%axis([1.3795E9,1.3E9,-inf,7000]) %can change the axis to zoom in on certain events

%convert the index to time and replot against time
Sampling_rate = 200/(10^3); % CHANGE FOR EVERY FILE: take the sample rate from the file name (in ms) and convert to seconds
time_real = time*Sampling_rate; % the index is multiplied by the sampling rate provided in the file name


%plot(time_real,power) %time is in seconds
%axis([-inf,inf,-inf,7000]) %adjust so in seconds from the axis above which is in the index

%%Experiment with smoothing functions
power_smoothed = smooth(power);
power_smoothed155 = smooth(power, 155);
%power_smoothed_rloess = smooth(power, 'rloess');
power_smoothed_rloess = smooth(power, 75, 'rloess');
figure
subplot(2,1,1)
plot(time_real, power)
%subplot(2,1,2)
%plot(time_real, power_smoothed)
%subplot(2,1,2)
%plot(time_real, power_smoothed155)
subplot(2,1,2)
plot(time_real, power_smoothed_rloess)



%Previous attempt to try and find events
%Value=power(694146)
%Max = max(power);
%Index = find(power==Max);
%Time = time(Index);
%time_total = max(time)