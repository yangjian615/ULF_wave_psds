%HISTORY
% 15-12-09 Step 6 moved here rather than inside calc_psds.
% 15-12-18 Step 6 completed
% 16-01-26 Changes for test data: all steps on, 
% 16-02-01 Different thresholding limits for test data


% Pulls together all the preprocessing in MATLAB.

% In general we don't do anything if the resultant file already exists.
% This is true for data_prep and sort_by_hour. However, fix_moved_hours and
% do_thresholding will just overwrite any existing files.


% pp_step1 = reading in the data, done in Python
% pp_step2 = rotating to magnetic north, converting to magnetic local time,
%       tidy up date columns
% pp_step3 = sorting by hour
% pp_step4 = gluing the bits of hour togther. Will ALWAYS need to run on
%       ALL years.
% pp_step5 =  thresholding and removing spare slices.
% pp_step6 = Removing any hours where the OMNI data is missing.


function [] = matlab_preprocessing(win_mins)
    
	
    stations = {'GILL'};%,'PINA','FCHU','ISLL'};%{'GILL','FCHU','ISLL','PINA'};
    years = 1990:2005;
    months = 1:12;%[1:12];
    data_dir = strcat(pwd,'/data/');%'/glusterfs/scenario/users/mm840338/data_tester/data/';%'/net/glusterfs_phd/scenario/users/mm840338/data_tester/data/';%strcat(pwd,sprintf('/data/'));
    %win_mins = 90; % in minutes
	data_t_res = 5; %every 5 seconds using CANOPUS data, will need to change for CARISMA
	

	% set global variable for tracing
	set_ptag(2);
	ptag = get_ptag();

	
    do_omni = false; res_opts = 'low_res';  %true;
    do_prep = false;%true;
    do_thresh = false;%true; 
	interpolate_missing = false;%true; %for omni data AND CANOPUS
    do_hr_sort = false;%true;
    do_hr_fix =false;% true; %should always run if re-sorting by hour 
	do_omni_hr_sort =false;%true;
    do_omni_remove = false;%rue;%
	do_calc_psds = true;
    
	 %threshold values
	z_lim =[5.8e4,6.4e4];
	
	% MLT sectors
	%day_ranges = [ 3, 9 ; 9, 15; 15, 21 ;21,3];
    
		
	% checks
	if win_mins > 28*24*60
		error('Cant currently have windows larger than a month');
	end
    
    for station_cell = stations
		station = char(station_cell);
		
		% make get_opts struct for this run
		data_opts = [];
		data_opts.station = station;
		data_opts.y = years;
		data_opts.m = months;
		data_opts.win_mins = win_mins;
		
		check_basic_struct(data_opts,'get_opts');
   
		do_print(ptag,1,sprintf('matlab_preprocessing: Processing %s with %d minute windows\n',station,data_opts.win_mins));
		
		if do_omni
			
			do_print(ptag,1,'matlab_preprocessing: Reading in omni data\n');
			read_in_omni_data( data_dir, data_opts, res_opts );
			
			% get variation of parameters
			% these are calculated separ
			%if strcmp(res_opts,'high_res')
			
			%end
			
			if interpolate_missing && mod(win_mins,60) ~= 0 % fill in gaps if using 1min data
				
				do_print(ptag,1,'matlab_preprocessing: interpolating OMNI data\n');
				
				for year = years
					for month = months
				
						f_to_load = strcat(data_dir,sprintf('omni_1min/prepped/%s_omni_1min_%d_%d_%d',station,win_mins,year,month));
						f_to_save = strcat(data_dir,sprintf('omni_1min/fixed/%s_omni_1min_%d_%d_%d',station,win_mins,year,month));
						
						if exist(strcat(f_to_load,'.mat'),'file')
							load(f_to_load);
							do_print(ptag,2,sprintf('matlab_preprocessing: Interpolating OMNI data for %d month %d \n',year,month));
							
							omni_data = interpolate_omni( omni_data, data_opts );
							
							if ~isempty(omni_data) && min(size(omni_data)) > 0
								save(f_to_save,'omni_data');
							else do_print(ptag,2,'matlab_preprocessing: Nothing to save!!\n'); 
							end
						else do_print(ptag,2,'matlab_preprocessing: Nothing to load in for OMNI interpolation\n');
						end
					end
				end
			end
			
		end
		
		% do stuff in blocks where possible to prevent unnecessary reading in and out. 
		if do_prep || do_thresh || do_hr_sort 
			for year = years
				for month = months
					
					data = [];
					if do_prep
						f_to_load = strcat(data_dir,sprintf('/raw/%s_%d_%d',station,year,month));
						f_to_save = strcat(data_dir,sprintf('/prepped/%s_%d_%d',station,year,month));
						
						do_print(ptag,1,sprintf('matlab_preprocessing: Doing data_prep on %s, year %d\n',station,year));
						
						if exist(strcat(f_to_load,'.mat'),'file')
						
							load(f_to_load);	
							do_print(ptag,2,sprintf('matlab_preprocessing: data_prep for month %d\n',month));
							
							data = data_prep( data, data_dir, data_opts, year );
							
							if ~isempty(data) && min(size(data)) > 0
								do_print(ptag,4,'matlab_preprocessing: saving prepped data\n');
								save(f_to_save,'data');
							else do_print(ptag,2,'matlab_preprocessing: Nothing to save!!\n'); 
							end
						else do_print(ptag,2,sprintf('matlab_preprocessing: No file to load for data_prep, %s %d month %d\n',station,year,month));
						end
					end
					
					if do_thresh
						
						f_to_load = strcat(data_dir,sprintf('/prepped/%s_%d_%d',station,year,month));
						f_to_save = strcat(data_dir,sprintf('/thresholded/%s_%d_%d_%d',station,win_mins,year,month));
						
						do_print(ptag,1,sprintf('matlab_preprocessing: Doing thresholding on %s, year %d\n',station,year));
						
						% now need to check correct data exists
						if exist(strcat(f_to_load,'.mat'),'file')
							
							do_print(ptag,2,sprintf('matlab_preprocessing: thresholding for month %d\n',month));
							if ~do_prep
								load(f_to_load);	
							end
							
							data = do_thresholding( data, data_opts, z_lim, interpolate_missing, data_t_res );
													
							if ~isempty(data) && min(size(data)) > 0
								save(f_to_save,'data');
							else do_print(ptag,2,'matlab_preprocessing: Nothing to save!!\n'); 
							end
						else do_print(ptag,2,sprintf('matlab_preprocessing: No file to load for thresholding, %s %d month %d\n',station,year,month));
						end
						
					end
					
					if do_hr_sort
					
						f_to_load = strcat(data_dir,sprintf('/thresholded/%s_%d_%d_%d',station,win_mins,year,month));
						f_to_save = strcat(data_dir,sprintf('/sorted1/%s_%d_%d_%d',station,win_mins,year,month));
					
						do_print(ptag,1,sprintf('matlab_preprocessing: Doing CANOPUS window sorting on %s, year %d\n',station,year));
					
						if exist(strcat(f_to_load,'.mat'),'file')
							
							do_print(ptag,2,sprintf('matlab_preprocessing: Sorting into windows, month %d\n',month));
							if ~do_thresh
								load(f_to_load);
							end
							
							data = sort_by_hour( data, data_opts, data_t_res );
			
							if ~isempty(data) && min(size(data)) > 0
								save(f_to_save,'data','-v7.3');
							else do_print(ptag,2,'matlab_preprocessing: Nothing to save!!\n'); 
							end
						else do_print(ptag,2,sprintf('matlab_preprocessing: No file to load for thresholding, %s %d month %d\n',station,year,month));
						end
					end
				end
			end
		end
		
		if do_hr_fix
		
			do_print(ptag,1,sprintf('matlab_preprocessing: Fixing all moved hours\n'));
			fix_moved_hours( data_dir, station, data_opts, data_t_res );
		
		end
		
		if do_omni_hr_sort% now get the relevant omni length windows
		
			do_print(ptag,1,sprintf('matlab_preprocessing: Sorting omni hours\n'));
			sort_omni_by_hour( data_dir, data_opts, data_t_res, 0.5 );
			
		end
		
		
		if do_omni_remove || do_calc_psds
		
			if do_omni_remove && mod(win_mins,60) == 0
				load(strcat(data_dir,sprintf('%s_omni_%d',station,win_mins)));
			end
			
			
			for year = years
				for month = months
				
					if do_omni_remove				
						f_to_load = strcat(data_dir,sprintf('sorted2/%s_%d_%d_%d',station,win_mins,year,month));
						f_to_save = strcat(data_dir,sprintf('structured/%s_%d_%d_%d',station,win_mins,year,month));
					
						do_print(ptag,1,sprintf('matlab_preprocessing: Matching OMNI, CANOPUS windows for %s, year %d\n',station,year));
					
						if mod(win_mins,60) ~=0
							fomni_to_load = strcat(data_dir,sprintf('omni_1min/sorted1/%s_omni_1min_%d_%d_%d',station,win_mins,year,month));
						end
						
						if exist(strcat(f_to_load,'.mat'),'file')
							load(f_to_load);
							if mod(win_mins,60) == 0 || exist(strcat(fomni_to_load,'.mat'),'file')% we can do the function!
								if mod(win_mins,60) ~= 0; load(fomni_to_load); end
								do_print(ptag,2,sprintf('matlab_preprocessing: Structuring data and OMNI data for month %d \n',month));
							
								[data] = remove_bad_omni( data, omni_data );
								
								if ~isempty(data) && min(size(data)) > 0
									save(f_to_save,'data');
								else do_print(ptag,2,'matlab_preprocessing: Nothing to save!!\n'); 
								end
								
							else do_print(ptag,2,'matlab_preprocessing: No omni data to use\n');
							end
						else do_print(ptag,2,sprintf('matlab_preprocessing: No file to load for matching to OMNI, %s %d month %d\n',station,year,month));
						end
					end
					
					if do_calc_psds
						
						f_to_load = strcat(data_dir,sprintf('structured/%s_%d_%d_%d',station,win_mins,year,month));
						f_to_save = strcat(data_dir, sprintf('psds/%s_%d_%d_%d',station,win_mins,year,month));
						
						do_print(ptag,1,sprintf('matlab_preprocessing: Calculating PSD for %s, year %d\n',station,year));
						
						if exist(strcat(f_to_load,'.mat'),'file')
						
							do_print(ptag,2,sprintf('matlab_preprocessing: calculating psds for month %d\n',month));
							
							if ~do_omni_remove
								load(f_to_load);
							end
							
							[data] = get_save_psds( data, data_opts );
							
							if ~isempty(data) && min(size(data)) > 0
								save(f_to_save,'data');
							else do_print(ptag,2,'matlab_preprocessing: Nothing to save!!\n'); 
							end
						else do_print(ptag,2,sprintf('matlab_preprocessing: No file to load for calculating psds, %s %d month %d\n',station,year,month));
						end
					end
				end
			end
		end
		
	end


end