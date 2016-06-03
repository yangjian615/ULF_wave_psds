% Wrapper to generalise when running functions over frequencies for omni field scatter data. 
% For examples see functions plot_mean_var_scatter_slice_normal_fits OR plot_power_ofield_scatter
%
% If you want to use the output, it should all be in a struct. Otherwise you will need to supply an empty output fiedl :(

function [output_struct] = wrapper_power_ofield_scatter( data, gen_opts, freq_opts, nbins, fn_to_do )


	if isempty(gen_opts)
		gen_opts = make_basic_struct('gen_opts');
	end
	if isempty(nbins)
		nbins = [15,80];
	end
	if isempty(freq_opts)
		freq_opts = make_basic_struct('multifreq_opts');
	elseif isfield(freq_opts,'single_freq') & ~isempty(freq_opts.single_freq) % can only specify a number of freqs OR single freq
		freq_opts.nfreqs = 1;		
	elseif isfield(freq_opts,'nfreqs')
		freq_opts.single_freq = [];
	end
	
	coord = gen_opts.coord;
	pop = gen_opts.pop;
	o_f = gen_opts.of;
	f_lim = gen_opts.f_lim;
	power_lims = gen_opts.pop_lim;
	o_f_lims = gen_opts.of_lim;
	
	axis_lim = [-inf,inf,0.5e-3,0.5e7];
	
	% all will have log axis for power
	
	
	freqs = calcfreqs(cell2mat({data(1).x}),data(1).times,[] );
	
	% get either a single freq or however many freq slices
	sf = freq_opts.single_freq;
	numfreqs = freq_opts.nfreqs;
	f_slices = [];
	if isempty(sf)
		f_slices = get_sample_freqs(numfreqs,freqs,gen_opts.f_lim);
	end
	if ~isempty(sf) & numfreqs ~= 1
		error('do single or multiple freqs??');
	end
	
	[pl_rows,pl_cols] = picknumsubplots(numfreqs);
	for f_count = [1:numfreqs]
		if ~isempty(sf)
			this_f = sf;
		else 
			this_f = f_slices(f_count);
		end
		
		power = cell2mat({data.(sprintf('%s%s',coord,pop))});
		power = power(freqs == this_f,:);
		
		omni_vals = cell2mat({data.(o_f)});
		
		ok_vals = (power >= power_lims(1)) & (power < power_lims(2)) ...
			& (omni_vals >= o_f_lims(1)) & (omni_vals <= o_f_lims(2));

		xs = omni_vals(ok_vals); %eg SW speed
		ys = power(ok_vals); % power
		
		% now do whatever you want here using xs,ys,this_f,fcount,pl_rows,pl_cols
		for_fn = [];
		for_fn.xs = xs;
		for_fn.ys = ys;
		for_fn.freqs = freqs;
		for_fn.this_f = this_f;
		for_fn.f_count = f_count;
		for_fn.pl_rows = pl_rows;
		for_fn.pl_cols = pl_cols;
		for_fn.gen_opts = gen_opts; for_fn.freq_opts = freq_opts; for_fn.nbins = nbins;
		
		[output_struct] = fn_to_do(for_fn);
		
		
	end
	
	
end