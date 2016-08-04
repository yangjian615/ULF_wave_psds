% Taken from code in do_thresholding so we can extend to OMNI data.
% We expect this to run on each month at a time, although you can feed in whatever data you want.
%
% data_to_fix will have each column specified in which_cols fixed. It's expected that the time difference between rows is constants and 
%		anything we wamt to interolate is a NaN
% chunk_lengths is the size of each lump we use to decide (very roughly!) whether it's worth fixing
% max_gaps is the maximum number of NaN allowed in this time (across ALL columns)

function [fixed_data] = interpolate_fix( data_to_fix, which_cols, chunk_lengths, max_gaps  )

	ptag = get_ptag();
	do_print(ptag,2,sprintf('interpolate_fix: entering function, checkin chunks of total %d points for max number of gaps %d\n',chunk_lengths*length(which_cols),max_gaps));
	% note: THIS IS DIVIDED BETWEEN ALL DIMENSIONS ACROSS TOO, eg 30 gaps over a many x 3 matrix is equivalent to 10 gaps in each row. Roughly.
	
	
	good_data = ~isnan(data_to_fix(:,which_cols));
    try_fix = ~good_data; % will now only do it if not too many in an hour
        
	fix_length = length(data_to_fix);		
	
	num_to_fix = sum(sum(try_fix)); num_good = sum(sum(good_data));
	%fprintf('interpolate_fix: ratio of missing data before interpolation is %d\n', num_to_fix/(num_to_fix+num_good));
	
	% see whether wort attempting to fix - check each chunk at a time isn't too gappy to identify fix indices
	for chunk_num = 1:floor(fix_length/chunk_lengths)
		endpoint = min( [chunk_lengths*(chunk_num) fix_length] );
		these_inds = [chunk_lengths*(chunk_num-1)+1:endpoint];
		if sum(sum(try_fix(these_inds,:))) > max_gaps
			try_fix(these_inds,:) = false;
		end
	end
	
	%fprintf('interpolate_fix: Trying to fix %d data points this month\n',sum(sum(try_fix)));
	indices = [1:fix_length];

	% fix it
	for col_ind = 1:length(which_cols)
		col = which_cols(col_ind);
		this_try_fix = try_fix(:,col_ind);
		this_good_data = good_data(:,col_ind);
		data_to_fix(this_try_fix,col) = interp1(indices(this_good_data),data_to_fix(this_good_data,col),indices(this_try_fix));
	end

	
	do_print(ptag,3,sprintf('interpolate_fix: interpolated an additional %d points\n',sum(sum(~isnan(data_to_fix(:,which_cols)))) - num_good));
	
	gappy_data = sum(isnan(data_to_fix(:,which_cols)),2);
	fixed_data = data_to_fix(~gappy_data,:);
	
	
end