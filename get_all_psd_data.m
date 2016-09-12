
% Load in ALL the data into huge thing
% Originally used in get_psd_medians


function [all_data] = get_all_psd_data(data_dir,get_opts);

	ptag = get_ptag();

	if isempty(get_opts)
		get_opts = make_basic_struct('get_opts');
		%get_opts.station = 'GILL';
		%get_opts.y = [1990:2004];
		%get_opts.m = [1:12];
	end
	
	station = get_opts.station;
	years = get_opts.y;
	months = get_opts.m;	
	win_mins = get_opts.win_mins;

	all_data = [];
	data = [];
	
	for year = years
		for month = months
			f_to_load = strcat(data_dir,sprintf('psds/%s_%d_%d_%d.mat',station,win_mins,year,month));
			%f_to_load = strcat(data_dir,sprintf('psds/%s_%d_%d.mat',station,year,month));
			if exist(f_to_load) ~= 2 
				warning(sprintf('>>> Could not load file <<< %s',f_to_load));
			else
				load(f_to_load);
				do_print(ptag,2,sprintf('Loading PSD data for %s, year %d month %d, window length %d minutes\n',station, year, month, win_mins)); 
				%now have data and data_bins and freqs
				all_data = [all_data,data];
			
			end
		end
	end
end