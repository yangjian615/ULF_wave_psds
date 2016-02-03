% Finds the average (median) speed of teh solar wind over our 15 years

data_dir = strcat(pwd,'/data/');
data = dlmread(strcat(data_dir,'omni2_all_years.dat')); 

% get stuff from the 15 years of interest
y = data(:,1);
our_years = y >= 1990 & y <= 2004;
our_data = data(our_years,:);

% get these speeds
our_speeds = our_data(:,25);

% remove anomalous ones
bad_data = our_speeds == 9999;
our_speeds(bad_data,:) = [];

disp(median(our_speeds));

%and again for all data
all_speeds = data(:,25);
bad_data = all_speeds == 9999;
all_speeds (bad_data,:) = [];

disp(median(all_speeds));