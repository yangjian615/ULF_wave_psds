% Newer version of norm_scatter_slice
% Normalises by the amount of each data in each bin, and then by overall data

function [] = plot_norm_scatter_slice( data, gen_opts, freq_opts, nbins );

	ptag  =get_ptag();

	if isempty(gen_opts)
		gen_opts = make_basic_struct('gen_opts');
		gen_opts.of_lim = [250,780]; % need this!
	elseif strcmp(gen_opts.of,'Np') & gen_opts.of_lim(2) == inf %set limits 
		do_print(ptag,3,'Setting limit for Np values');
		gen_opts.of_lim = [0.3,30];% may want to reduce further
	end
	
	wrapper_power_ofield_scatter(data,gen_opts,freq_opts,nbins,[],@guts_plot_norm_scatter_slice);
	
end
