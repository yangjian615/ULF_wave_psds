% Takes in a data and plots the median and upper/ lower quartiles for th coordinate of psd data
% all_selections is a cell of individual selections, which need to be quantile_selection structs


function [] = plot_median_and_quartiles( data, all_selections, coord )

	extras= [];
	extras.coord = coord;
	
	
	wrapper_freq_on_x_axis(data,all_selections,extras,@guts_plot_median_and_quartiles);

	
end

% Actually what I think I want to do is the normalised power intesnity slice plotts with x axis freq and y aixs psd for the given data.


	
	
