% get the values of the quantiles in all the station data

function [quants] = get_omni_quantiles( data_dir, station, num_q, omni_field, one_omni, win_mins )

	collect_omni = [];
	if one_omni
		disp('Getting qunatiles of low-res data file');
		f_to_open = strcat(data_dir,sprintf('%s_omni_%d',station,win_mins));
		load(f_to_open);
	else
		disp(sprintf('Getting quantiles of uninterpolated unsorted 1min data ("prepped") from 1990 to 2004, %d minute windows, omni field %s',win_mins,omni_field)); %just using win_mins sorting as easier to get data
		for year = [1990:2004]
			for month = [1:12]
			
				f_to_open = strcat(data_dir,sprintf('omni_1min/prepped/%s_omni_1min_%d_%d_%d',station,win_mins,year,month)); 
				
				if exist(strcat(f_to_open,'.mat'))
					load(f_to_open);
					
					if isempty(collect_omni)
						collect_omni = omni_data';
					else
						collect_omni = [collect_omni,omni_data'];
					end
				end
			end
		end
		omni_data = collect_omni;
	end
				
	
	quants = quantile(cell2mat({omni_data.(omni_field)}),[1:num_q-1]/num_q);

end