% Taken from code in do_thresholding so we can extend to OMNI data.
% We expect this to run on each month at a time, although you can feed in whatever data you want.
%
% data_to_fix will have each column specified in which_cols fixed. It's expected that the time difference between rows is constants and 
%		anything we wamt to interolate is a NaN
% chunk_lengths is the size of each lump we use to decide (very roughly!) whether it's worth fixing
% max_gaps is the maximum number of NaN allowed in this time (across ALL columns)

function [fixed_data] = interpolate_fix( data_to_fix, which_cols, chunk_lengths, max_gaps  )


	warning('Selection of areas worth fixing is dodgy');
	
	good_data = ~isnan(data_to_fix(:,which_cols));
    try_fix = ~good_data; % will now only do it if not too many in an hour
        
	fix_length = length(data_to_fix);		
	
	
	% see whether wort attempting to fix - check each chunk at a time isn't too gappy
	for chunk_num = [1:floor(fix_length/chunk_lengths)]
		endpoint = min( [chunk_lengths*(chunk_num) fix_length] );
		these_inds = [chunk_lengths*(chunk_num-1)+1:endpoint];
		if sum(sum(try_fix(these_inds,:))) > max_gaps
			try_fix(these_inds,:) = false;
		end
	end
	
	disp(sprintf('Trying to fix %d data points this month',sum(sum(try_fix))));
	indices = [1:fix_length];

	% fix it
	for col_ind = [1:length(which_cols)]
		col = which_cols(col_ind);
		this_try_fix = try_fix(:,col_ind);
		this_good_data = good_data(:,col_ind);
		data_to_fix(this_try_fix,col) = interp1(indices(this_good_data),data_to_fix(this_good_data,col),indices(this_try_fix));
	end

	
	warning('have you fixed the dates part that was here??');
	
	gappy_data = sum(isnan(data_to_fix(:,which_cols)),2);
	fixed_data = data_to_fix(~gappy_data,:);
	
	
end