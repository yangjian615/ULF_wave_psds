% get the values of the quantiles in all the station data

function [quants] = get_omni_quantiles( data_dir, station, num_q, omni_field )
	
	f_to_open = strcat(data_dir,sprintf('%s_omni',station));
	load(f_to_open);
	
	quants = quantile(cell2mat({omni_data.(omni_field)}),[1:num_q-1]/num_q);

end