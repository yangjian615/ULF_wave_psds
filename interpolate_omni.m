% Interpolation of gaps in omni data, using same code as for CANOPUS data


function [output_data] = interpolate_omni( omni_data, data_opts )

	ptag = get_ptag();
	do_print(ptag,2,'interpolate_omni: entering function\n');
	
	win_mins = data_opts.win_mins;
	
	o_fields = fieldnames(omni_data);
	o_length = length(omni_data);

	% transfer all omni data into matrix for fixing
	o_mat = nan(o_length,length(o_fields));
	for of_count = 1:length(o_fields)
		o_mat(:,of_count) = cell2mat({omni_data.(o_fields{of_count})});
	end
	
	% make matrix with gaps for missing data
	to_fix = make_gappy_matrix_by_date( o_mat, 60 );
	
	mins_to_fix = 8; %how many minutes out of each hour will we try
	do_print(ptag,2,sprintf('interpolate_omni: Currently fixing up to %d mins out of each hour for each col. of omni data used\n',mins_to_fix));
	data = interpolate_fix( to_fix, 2:length(o_fields), win_mins, (length(o_fields)-1)*ceil((mins_to_fix/60)*(win_mins)) ); 

	% now read back into sturcture
	omni_data = [];
	for of_count =  1:length(o_fields)
		this_data = num2cell(data(:,of_count));
		[omni_data(1:size(data,1)).(o_fields{of_count})] = this_data{:};
	end
			
			
	output_data = omni_data;




end
	