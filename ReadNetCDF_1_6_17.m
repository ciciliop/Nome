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

%Open the NetCDF file%
ncid = netcdf.open('Nome-C1-FedP@2013-09-01T000000Z@P1M@PT365F@V0.nc', 'NC_NOWRITE'); %copy and paste file name
time = netcdf.getVar(ncid,0); %getting index out of file, which is labeled as time
power = netcdf.getVar(ncid,1); %getting data out of file
Power = [time, power]; %combing index and data into a matrix
%use ncdisp to get information about the contents of the netcdf file
%will want to load in all files and come up with a labeling system

%%Convert epoch time to real time
% for i = 1:length(time/8)
%     time_real = datestr(719529+time(i)/86400, 'HH:MM:SS.FFF');
%     time_date(i,1:12) = time_real;
% end
% This is commented out because it is too much data to store, will just use
% as seconds and convert to days

%%Convert epoch time(seconds) to days
% time_days = time;
% for i = 1:length(time)
%     time_days(i) = time(i)/86400;
% end


%%Convert to P.U.
% Data is recorded in KVA and V
% Bus 2: C1 and C2: 
Sbase = 10000; %KVA (10 MVA)
Vbase = 4160; %V (4.16kV)
power_pu = power/Sbase; %change for everytime you switch between P/Q and V


%%Create replacement values for the zeros
mean = mean(power_pu);

%%Remove the zeros and replace with mean
for i = 1:length(power)
%     if std_m_10(i) > 1000 %Leave out for now because I can't cleanly
%     identify the close to zero values
%         power_cleaned(i) = power_smoothed(i);
    if power(i)==0
        power_wo_zero(i) = mean;        
    else 
        power_wo_zero(i) = power_pu(i);
    end
end

%Create smoothed values to replace the means
power_smoothed = smooth(power_wo_zero,50);

%%Remove the mean values with smoothed values (that had zeros previous removed)
for i = 1:length(power)
    if power(i)==0
        power_cleaned(i) = power_smoothed(i);        
    else 
        power_cleaned(i) = power_pu(i);
    end
end
power_cleaned = power_cleaned'; % flipping data back to in columns

%%Create Universal Time Index

%Pick starting  and ending time (will be set for all files) set to one day
total_index_length_orig = length(time);
start_index_orig = round(total_index_length_orig/30*13);
end_index_orig = round(total_index_length_orig/30*14);
time_start_orig = time(start_index_orig);
time_end_orig = time(end_index_orig);


%Save all pertinent information to clean rest of data at bus
important_data = [time_start_orig ;  time_end_orig];
save('test_data_start_end.mat', 'important_data')

%Average every .1 seconds, creating new time data file
total_index_length_new = round((time_end_orig-time_start_orig)/.1); %detemine length of new time data file
time_uni(1) = time_start_orig;
for i = 2:total_index_length_new
    j = i-1;
    time_uni(i) = time_uni(j)+.1;
    %power_uni(i) = mean(power(time_universal(i):time_universal(j)));
end

%%Don't average, set it to the value at the closest equivalent time
%%(below), with overspecified time interval
power_uni(1) = power_cleaned(start_index_orig);
for k = 2:total_index_length_new
    l = k-1;
    temp = 0;
    for j = start_index_orig:end_index_orig
        if (time(j)>=time_uni(l) && time(j)<=time_uni(k))
            temp = power_cleaned(j);
        end
    end
    if temp == 0
        power_uni(k) = power_uni(l);
    else       
        power_uni(k) = temp;
    end
    
end

%Compare original power in same time frame to that on universal
power_section = power(start_index_orig:end_index_orig);
time_section = time(start_index_orig:end_index_orig);

figure
subplot(2,1,1)
plot(power_section)
title('Original')
subplot(2,1,2)
plot(power_uni)
title('New Indexing')



%Save output to file
save('test_time_orig.mat', 'time_section')
save('test_time.mat', 'time_uni')
save('test_data_orig.mat', 'power_section')
save('test_data_new.mat', 'power_uni')


