% You can put in a vector for ratio" and it will calculate all of them


function [] = plot_scatter_and_slice_upper_bound( data, gen_opts, f_opts, nbins,ratio )


	if isempty(gen_opts)
		gen_opts = make_basic_struct('gen_opts');
		gen_opts.of_lim = [250,780]; % need this!
	elseif strcmp(gen_opts.of,'Np') & gen_opts.of_lim(2) == inf %set limits
		disp('Setting limit for Np values');
		gen_opts.of_lim = [0.3,30];% may want to reduce further
	end
	
	
	extras = [];
	extras.ratio = ratio;
	
	wrapper_power_ofield_scatter(data,gen_opts,f_opts,nbins,extras,@guts_plot_scatter_and_slice_upper_bound);
		
	
end