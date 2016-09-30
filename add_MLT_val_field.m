% Adds the annual MLT midnight value to data

function [output]  = add_MLT_val_field( data, data_dir, data_opts  )

	ptag = get_ptag();
	do_print(ptag,2,'add_MLT_val_field: entering function, adding L values \n');
	
	station_data = [];
	load(strcat(data_dir,sprintf('%s_data_struct',data_opts.station))); 
	
	all_years = cell2mat({data.orig_dates});
	all_years = datevec(all_years);
	all_years = all_years(:,1);
	
	each_mlt = nan(size(all_years));
	for y_count = 1:length(station_data)
		
		this_year = station_data(y_count).year;
		this_mlt = station_data(y_count).MLT;
		
		each_mlt( all_years == this_year ) = this_mlt;

	end
	
	if sum(isnan(each_mlt)) > 0
		error('add_MLT_val_field:NotComplete',' some entries were not allocated an  mlt value');
	end

	each_mlt = num2cell(each_mlt);
	
	output = data;
	[output.MLT_val] = each_mlt{:};



end