% Looks at the distibtion for several different freqs
% Normalises
% Takes slices of this
% Calculates mean and variance
% PLots these against each other, also the resulting normal distn on top of results

% Uses log(power) to make the distributions easier

function [gen_opts] = plot_mean_var_scatter_slice_normal_fits( data, gen_opts, freq_opts, nbins, nfit_choice )
	
	extras = [];
	
	if isempty(gen_opts)
		gen_opts = make_basic_struct('gen_opts');
		gen_opts.of_lim = [250,780]; % need this!
	end
	
	% handle which bit we're using
	if ~isempty(nfit_choice)
		if strcmp(nfit_choice,'plot_fits') | strcmp(nfit_choice,'mv_scatter') | strcmp(nfit_choice,'qqplots') 
			extras.nfit_opts = nfit_choice;
		else
			error('Bad option');
		end
	else
		extras.nfit_opts = 'plot_fits';
	end
	
	wrapper_power_ofield_scatter(data,gen_opts,freq_opts,nbins,extras,@guts_plot_mean_var_scatter_slice_normal_fits);

end
	