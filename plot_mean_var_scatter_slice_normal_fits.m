% Looks at the distibtion for several different freqs
% Normalises
% Takes slices of this
% Calculates mean and variance
% PLots these against each other, also the resulting normal distn on top of results

% Uses log(power) to make the distributions easier

function [gen_opts] = plot_mean_var_scatter_slice_distns( data, gen_opts, freq_opts, nbins )
	
	if isempty(gen_opts)
		gen_opts = make_basic_struct('gen_opts');
		gen_opts.of_lim = [250,780]; % need this!
	end
	
	wrapper_power_ofield_scatter(data,gen_opts,freq_opts,nbins,@guts_plot_mean_var_scatter_slice_normal_fits);

end
	