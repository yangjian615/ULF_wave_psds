% PLot scatter plot and intensity map of data points by omni field

function [] = plot_power_ofield_scatter( data, gen_opts,freq_opts, nbins )

	wrapper_power_ofield_scatter(data,gen_opts,freq_opts,nbins,@guts_plot_power_ofield_scatter);
	
	
end