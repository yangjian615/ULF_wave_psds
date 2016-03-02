% get the values of the quantiles in all the station data

function [quants] = get_omni_quantiles( data_dir, station, num_q, omni_col )
	
	f_to_open = strcat(data_dir,sprintf('%s_omni',station));
	load(f_to_open);
	
	quants = quantile(omni_data(:,omni_col),[1:num_q-1]/num_q);

end