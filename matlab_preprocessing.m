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


function [] = matlab_preprocessing()
    
    stations = {'GILL'};%,'PINA','FCHU','ISLL'};%{'GILL','FCHU','ISLL','PINA'};
    years = [1990:2005];
    months = [1:12];
    data_dir = '/net/glusterfs_phd/scenario/users/mm840338/data_tester/data/';%strcat(pwd,sprintf('/data/'));
    window_length = 60*60; % in seconds, should be a multiple of minutes? then use 1min OMNI?
	data_t_res = 5; %every 5 seconds using CANOPUS data, will need to change for CARISMA
	
	
    do_omni = false;%true;
  
    do_prep = false;%true;
    do_thresh = false;%true; interpolate_missing = true; save_removed = false; %saving the removed makes twice as long
    do_hr_sort = false;%true;
    do_hr_fix = false;%true; %should always run if re-sorting by hour 
    do_omni_remove = false;%true; 
	do_the_binning = true;
	do_calc_psds = true;
	do_find_medians  =  false;
	%do_get_offset_data = false; %functionality needs restoring now we have structures
    
	 %threshold values
    z_low = 5.8e4;
    z_high = 6.4e4;
	
	% MLT sectors
	day_ranges = [ 3, 9 ; 9, 15; 15, 21 ;21,3];
    
		
	% checks
	if window_length > 28*24*60*60
		error('Cant currently have windows larger than a month');
	end
    
    for station_cell = stations
		station = char(station_cell);
		
		if strcmp(station,'TEST')
			do_omni = true;	
			do_prep = false;
			do_thresh = false; interpolate_missing = false; save_removed = false;%you may need to puyt in new threshold limits.
			do_hr_sort = false;
			do_hr_fix = false; %should always run if re-sorting by hour 
			do_omni_remove = true;
			
			z_low = -1.1;
			z_high = 1.1;
		end
   
		tic
		disp(sprintf('Doing the processing for %s with %d minute windows',station,window_length/60));
		
		if do_omni
			tic
			read_in_omni_data( data_dir, station, years, window_length, data_t_res );
			if interpolate_missing & mod(window_length,60^2) ~= 0 % fill in gaps if using 1min data
				interpolate_omni( data_dir, station, years, [1:12], window_length );
			end
			toc
		end
		
		if do_prep 
			tic
			data_prep( data_dir, station, years, months );
			toc
		end
		
		if do_thresh
			tic
			do_thresholding( data_dir, station, years, months, z_low, z_high, interpolate_missing, save_removed, window_length,data_t_res,[] );
			toc
		end
		
		if do_hr_sort
			tic
			sort_by_hour( data_dir, station, years, months, window_length, data_t_res );
			toc
		end
		
		if do_hr_fix
			tic
			fix_moved_hours( data_dir, station, window_length, data_t_res );
			toc
		end
		
		if do_omni & do_hr_sort% now get the relevant omni length windows
			sort_omni_by_hour( data_dir, station, years, months, window_length, data_t_res, 0.95 )
		end
		
		if do_omni_remove
			tic
			remove_bad_omni( data_dir, station, years, months, window_length );
			toc
		end
		
		if do_the_binning
			tic
			bin_data_structures(data_dir,station,years,months,day_ranges,window_length);
			toc
		end
		
		% if do_get_offset_data
			% tic
			% make_offset_data( data_dir,station,years,months );
			% toc
		% end

		if do_calc_psds    
			tic    
			get_save_psds( data_dir, station, years, months, window_length );
			toc
		end
		
		% refresh the overall speed-binned medians
		if do_find_medians
			tic
			refresh_meds();
			toc
		end
		
		toc
	end

end