
% Load in ALL the data into huge thing
% Originally used in get_psd_medians


function [all_data,data_bins] = get_all_psd_data(data_dir,station,years,months)

	all_data = [];
	data = [];
	data_bins = [];
	
	for year = years
		for month = months
			f_to_load = strcat(data_dir,sprintf('psds/%s_%d_%d.mat',station,year,month));
			if exist(f_to_load) ~= 2 
				warning(sprintf('>>> Could not load file <<< %s',f_to_load));
			else
				load(f_to_load);
				disp(sprintf('Loading PSD data for %s, year %d month %d',station, year, month)); 
				%now have data and data_bins
				all_data = [all_data,data];
			
			end
		end
	end
end