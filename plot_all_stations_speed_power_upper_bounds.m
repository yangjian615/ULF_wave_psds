% Does upper bound for all stations. I expect this will someday be superceded by a wrapper for all stations.
%
% Currently only for x coord as hand in [] for gen_opts, easily changed.

function [] = plot_all_stations_speed_power_upper_bounds(ddir,ratio)
	
	stations = {'FCHU','GILL','ISLL','PINA'};
	get_opts = make_basic_struct('get_opts');
	
	for st_count = [1:length(stations)]
		station = stations{st_count};
		get_opts.station = station;
		
		[data,bins] = get_all_psd_data(ddir,get_opts);
		
		plot_speed_power_upper_bounds(data,[],ratio);
	end
	
	legend(stations);
end