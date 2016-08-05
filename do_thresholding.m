%History
% 15-12-09 No longer spits out GILL_1990_1.m but GILL_sorted3_1990_1.m so
% omni checking is part of preprocessing
% 16-02-03 Save and load files from slightly different location


% Does the thresholding using certain values. After all other processing
% and sorting by hours, so expect to do on many slices.

% Also removes any incomplete slices.
% chunk_length is how long to check for interpolations. I think I've just fed in the number of data points in each window

function [output_data] = do_thresholding( data, get_opts, z_lim, interpolate_missing, data_t_res )

	ptag = get_ptag();
	
	win_mins = get_opts.win_mins;
	mins_to_fix = 5; %how many minutes out of every hour to fix?

    do_print(ptag,2,'do_thresholding: entering function\n');
    
    
	[data(:,8:10)] = remove_by_threshold(data(:,8:10),z_lim(1),z_lim(2));
	empty_rows = sum(data(:,8:10),2) == 0;
	do_print(ptag,3,sprintf('do_thresholding: removing %d empty rows\n',sum(empty_rows)));
	data = data(~empty_rows,:);
	
	
	% DUPLICATE DATA CHECK TOO EXPENSIVE? You could just remove it all if two different sets, that usually seems to be the case anyway
	% check for duplicate data, remove if same date different xyz
	[unique_dates,unique_date_indices] = unique(data(:,1));
	if length(unique_dates) ~= length(data)
		warning('>>> You have duplicate data.Checking it <<<');
		extra_data = data;
		extra_data(unique_date_indices,:) = [];
		e_size = size(extra_data);
		dels = false(length(data),1);
		for extra_entry = 1:e_size(1)
			corresp = data(:,1) == extra_data(extra_entry,1);
			if (sum( data(corresp,8:10) == extra_data(extra_entry) ) ~= 3) % two different sets of data, remove both
				dels(corresp) = true;
			else 
				do_print(ptag,3,'do_thresholding: Some duplicate data. Removing.\n');
				disp(extra_data);
			end
		end
		if sum(dels) > 1
			do_print(ptag,3,'do_thresholding: Two sets of data for same dates. Removing both sets of data.\n');
			data = data(~dels,:);
		end
	end
	[unique_dates,unique_date_indices] = unique(data(:,1)); % now getting rid of duplicate data. This will be done again if interpolating, unfortuately
	data = data(unique_date_indices,:);

	
	% interpolate anything missing if there is data left
	if interpolate_missing && min(size(data)) > 0
		do_print(ptag,2,sprintf('do_thresholding: try interpolate up to %d minutes missing per hour, checking in chunks of window length\n',mins_to_fix));
		
		% data should already be every five secs so no fancy date checking needed
		to_fix = make_gappy_matrix_by_date(data,5);
		
		win_length = win_mins*(60/data_t_res);
		data = interpolate_fix( to_fix, 8:10, win_length, 3*ceil((mins_to_fix/60)*(win_length)) );
		
		% now fill in datevec cols which we left alone
		data(:,2:7) = datevec(data(:,1));
		
	end
	
	% check we are at teh resolution required
                    
	output_data = data;
        
end