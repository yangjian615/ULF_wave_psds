% Adds the L-value to data using ORIGINAL date for that station

function [output]  = add_L_field( data, data_dir, data_opts )

	ptag = get_ptag();
	do_print(ptag,2,'add_L_field: entering function, adding L values \n');
	
	station_data = [];
	load(strcat(data_dir,sprintf('%s_data_struct',data_opts.station))); 
	
	all_years = cell2mat({data.orig_dates});
	all_years = datevec(all_years);
	all_years = all_years(:,1);
	
	each_L = nan(size(all_years));
	for y_count = 1:length(station_data)
		
		this_year = station_data(y_count).year;
		this_L = station_data(y_count).L;
		
		each_L( all_years == this_year ) = this_L;

	end
	
	if sum(isnan(each_L)) > 0
		error('add_L_field:NotComplete',' some entries were not allocated an L-value');
	end

	each_L = num2cell(each_L);
	
	output = data;
	[output.L] = each_L{:};




end