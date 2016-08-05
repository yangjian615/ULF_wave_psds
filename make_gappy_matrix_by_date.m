% Makes a nan matrix with a row for every datetime. Keeps data we already have.
% Originally from do_thresholding code, expanded for omni data. We expect to fix the resultant matrix, hence the name of output variable.
%
% Requirements:
% data: first column of data is datenums. Any formatting of these should already be included (eg rounding to 5secs, or all in 0secs)
% t_res: must supply required resolution in seconds

function [to_fix] = make_gappy_matrix_by_date( data, t_res )


	d_length = size(data,1);

	first_date = datevec(data(1,1)); 
	last_date = datevec(data(d_length,1));
	
	max_length = ceil(abs(etime(first_date,last_date)/t_res)); % how many datapoints do we expect at this time resolution?
	
	
	% make the list of all dates including missing ones - add in minutes then convert
	basis = ones(max_length,1);
	dates_mat = [first_date(1)*basis first_date(2)*basis first_date(3)*basis first_date(4)*basis first_date(5)*basis first_date(6)*basis];
	dates_mat(:,6) = dates_mat(:,6) + [0:max_length-1]'*t_res;
	dates = datenum(dates_mat); dates_mat = datevec(dates); dates = datenum(dates_mat);

	
	% make empty to stick all together then we can sort and keep unique dates (same as in do_thresholding)
	to_fix = nan(max_length+d_length,size(data,2)); 
	to_fix(1:d_length,:) = data; % first col would be dates
	to_fix(d_length+1:max_length+d_length,1) = dates;

	
	% sort into order and keep one of each date
	to_fix = sortrows(to_fix,1);  
	[unique_dates,unique_date_indices] = unique(to_fix(:,1));
	to_fix = to_fix(unique_date_indices,:);
	
	
	% Check correct time redolution	between rows - should be a multiple of t_res
	% this method of creating dates may be incorrect, eg the 'every 5s' 5, 10,15... pattern may be lost when converting over leap times.
	% can speed up by vectorising
	check_time_resolution(datevec(to_fix(:,1)),t_res);
	
	
			
end