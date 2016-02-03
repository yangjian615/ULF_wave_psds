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
    
    station = 'GILL';
    years = [1990:2004];
    months = [1:12];
    data_dir = strcat(pwd,sprintf('/data/'));
    
    do_omni = true;
    
    pp_step2 = true;
    pp_step3 = true;
    pp_step4 = true; %should always run if re-sorting by hour 
    pp_step5 = true; %will overwrite if already exists
    pp_step6 = true;
    
	 %threshold values
    z_low = 5.8e4;
    z_high = 6.4e4;
    
	if strcmp(station,'TEST')
		do_omni = true;	
		pp_step2 = false;
		pp_step3 = false;
		pp_step4 = false; %should always run if re-sorting by hour 
		pp_step5 = false; %you may need to puyt in new threshold limits.
		pp_step6 = true;
        
        z_low = -1.1;
        z_high = 1.1;
	end
		
    
   
    
    if do_omni
        tic
        read_in_omni_data( data_dir, station, years );
        toc
    end
    
    if pp_step2 
        tic
        data_prep( data_dir, station, years, months );
        toc
    end
    
    if pp_step3
        tic
        sort_by_hour( data_dir, station, years, months );
        toc
    end
    
    if pp_step4
        tic
        fix_moved_hours( data_dir, station );
        toc
    end
    
    if pp_step5
        tic
        do_thresholding( data_dir, station, years, months, z_low, z_high );
        toc
    end
    
    if pp_step6
        tic
        remove_bad_omni( data_dir, station, years, months );
        toc
    end


end