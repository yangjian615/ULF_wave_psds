% This function reads in the data and sorts it by hour - it returns the
% data with an extra dimension which is hour (this information is left in
% the matrices, so that the first column in every "slice" should contain
% the same hour with different time)

% We do it month by month.

%HISTORY
%16-01-04 Run even if results file already exists. Still check loading file
%OK.
%16-02-03 Save and load data from slightly different place


function [output_data] = sort_by_hour( data, get_opts, data_t_res  )
    
	ptag = get_ptag();
	do_print(ptag,2,'sort_by_hour: entering function\n');
	
	window_length = get_opts.win_mins*60; % window length in seconds
	window_data_num = window_length/data_t_res; % number of data points in each window
	

	max_month_secs = (31*24+7)*60*60;
	
	
	% set first time in month - start on the hour
	first_time = datevec(data(1,1));
	first_time(5:6) = [0 0];
	
	% you need extra windows to accommodate this shifting back to first full houradd these extra seconds
	max_month_windows = ceil( (max_month_secs + abs(etime(first_time, datevec(data(1,1))))) / window_length ); % get integer number of windows in month
	
	% set last time in month, add to end of data matrix to get correct 
	last_time = first_time;
	last_time(6) = last_time(6) + (max_month_windows*window_length) - data_t_res; 
	% max no. of windows  x no. secs n each, minus one data point as one already exists
	% rounded up to max no. of windows rather than to data_t_res - but make_gappy_matrix will check time resolution holds
	
	data_and_ends = vertcat([datenum(first_time) nan(1,9)],data,[datenum(last_time) nan(1,9)]);
	sorted_data = make_gappy_matrix_by_date(data_and_ends,data_t_res);
	
	% make datevec columns if necessary - we didn't both to fill out before handing in
	make_dates = isnan(sorted_data(:,2));
	sorted_data(make_dates,2:7) = datevec(sorted_data(make_dates,1));
	
	
	% put into slices shape
	sorted_data = reshape(sorted_data,window_data_num,[],10);
	sorted_data = permute(sorted_data,[1 3 2]);
	
	
	%% Check for good/ bad data in each slice.
	bad_data = sum(sum(isnan(sorted_data),2)); % count number of data in each slice
	
	% remove endpoints if fully bad and interiors if any nans
	to_keep = bad_data == 0;
	to_keep(1,end) = bad_data(1,end) < window_data_num*9;

	
	data = sorted_data(:,:,to_keep);
	
	
	% check ends, replace nans with zeros in preparation for fix_moved_hours
	for slice_ind = [1,size(data,3)];
		end_slice = data(:,:,slice_ind);
		end_bad_data = isnan(end_slice);
		end_slice(end_bad_data) = 0;
		if sum( sum( end_slice(:,8:10) ) ) > 0
			data(:,:,slice_ind) = end_slice;
		else
			data = data(:,:,([1:size(data,3)] ~= slice_ind));
		end
	end
		
	
	output_data = data;

end

