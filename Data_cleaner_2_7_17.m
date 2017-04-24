clc
clear
%%

% Note: This code accounts for the sampling rate to be at random 
% sampling according to UNIX epoch, which is defined as the number of 
% seconds since midnight Jan 1, 1970 UTC. 

%Instructions: This code is used for the first data file you clean at the 
% bus you are working on. Replace the file name at ncid for with the 
% filename you wish you clean. Change the per-unit conversion depending on
% what value is in the file. Adjust the new specified time end points to
% capture what looks like a disturbance and verify with Disturbance
% Dectector.

%Output: The original time and data values and the new time and data values
%that are recorded on a universal time index. Also the starting and ending
%times of the new time index (in epoch) are outputed so can be used for the
%rest of the file to be cleaned at the bus.

%Next Step: Use the Disturbance Dectector to flag where disturbances are
%then use the Other Files Data Cleaning to clean the rest of the files at
%the bus using the starting and ending times specified in this program. 

%% Opening and reading the Nome AK data %%

% %Open the NetCDF file%
% ncid = netcdf.open('Nome-C1-FedP@2013-09-01T000000Z@P1M@PT365F@V0.nc', 'NC_NOWRITE'); %copy and paste file name
% time = netcdf.getVar(ncid,0); %getting index out of file, which is labeled as time
% power = netcdf.getVar(ncid,1); %getting data out of file
% Power = [time, power]; %combing index and data into a matrix
% %use ncdisp to get information about the contents of the netcdf file
% %will want to load in all files and come up with a labeling system

%Upload CSV file
power = csvread('Outage_data_2_6_17_just_numbers.csv');
SNELL_V_C_Mag = power(:,1);
STATION_A_V_C_Mag = power(:,2);
GILBERT_V_C_Mag = power(:,3);
SNELL_V_B_Mag = power(:,4);
STATION_A_V_B_Mag = power(:,5);
GILBERT_V_B_Mag = power(:,6);
%%Create replacement values for the zeros
for j = 1:6
    mean_(j) = mean(power(1:1000,j));
end

%%Remove the zeros and replace with mean
for j = 1:6
for i = 1:length(power(:,1))
%     if std_m_10(i) > 1000 %Leave out for now because I can't cleanly
%     identify the close to zero values
%         power_cleaned(i) = power_smoothed(i);
    if power(i,j)==0
        power_wo_zero(i,j) = mean_(j);        
    else 
        power_wo_zero(i,j) = power(i,j);
    end
end
end
%Create smoothed values to replace the means
for j = 1:6
    power_smoothed(:,j) = smooth(power_wo_zero(:,j),5);
end


%%Remove the mean values with smoothed values (that had zeros previous removed)
for j = 1:6
for i = 1:length(power(:,1))
    if power(i,j)==0
        power_cleaned(i,j) = power_smoothed(i,j);        
    else 
        power_cleaned(i,j) = power(i,j);
    end
end
end
% power_cleaned = power_cleaned'; % flipping data back to in columns

