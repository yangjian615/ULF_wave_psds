% Wrapper to generalise when running functions over frequencies for omni field scatter data. 
% For examples see functions plot_mean_var_scatter_slice_normal_fits OR plot_power_ofield_scatter
%
% If you want to use the output, it should all be in a struct. Otherwise you will need to supply an empty output fiedl :(
%
% Also deals with MLT separations

function [output_struct] = wrapper_power_ofield_scatter( data, gen_opts, freq_opts, nbins, extras, fn_to_do )

	f_tol = 0.0001; % frequency tolerance
	disp(sprintf('freq tol is %d',f_tol));


	if isempty(gen_opts)
		gen_opts = make_basic_struct('gen_opts');
	end
	if isempty(nbins)
		nbins = [15,80];
	end
	if isempty(freq_opts)
		freq_opts = make_basic_struct('multifreq_opts');
	else
		check_basic_struct(freq_opts,'multifreq_opts');
	end
	
	coord = gen_opts.coord;
	pop = gen_opts.pop;
	o_f = gen_opts.of;
	f_lim = gen_opts.f_lim;
	power_lims = gen_opts.pop_lim;
	o_f_lims = gen_opts.of_lim;
	
	axis_lim = [-inf,inf,0.5e-3,0.5e7];
	
	% all will have log axis for power
	
	
	freqs = (data(1).freqs)*1e3;
	
	% initialise outpu which will remain empty or be added to each time
	output_struct = [];
	
	% get either a single freq or however many freq slices
	sf = freq_opts.single_freq;
	numfreqs = freq_opts.nfreqs;
	f_slices = [];
	if isempty(sf)
		if isempty(freq_opts.multi_freqs)
			f_slices = get_sample_freqs(numfreqs,freqs,gen_opts.f_lim);
		else
			f_slices = cell2mat({freq_opts.multi_freqs});
		end
	else 
		f_slices = sf;
	end

	
	[pl_rows,pl_cols] = picknumsubplots(numfreqs);
	
	% arrange MLT sector stuff
	if ~isempty(gen_opts.time_sectors)
		if strcmp(gen_opts.time_sectors,'four_sectors')
			MLT_count = 4;
			if numfreqs > 1
				warning('You havent got multi MLT multi freqs working yet');
			end
		else
			error('unknown MLT options');
		end
	else
		MLT_count = 1;
	end
	
	this_hf = [];
	for f_count = [1:numfreqs]
		this_f = f_slices(f_count);
		
		
		power = cell2mat({data.(sprintf('%s%s',coord,pop))});
		power = power( abs(this_f - freqs) < f_tol ,:);
		
		
		omni_vals = cell2mat({data.(o_f)});
		
		ok_vals = (power >= power_lims(1)) & (power < power_lims(2)) ...
			& (omni_vals >= o_f_lims(1)) & (omni_vals <= o_f_lims(2));

		xs = omni_vals(ok_vals); %eg SW speed
		ys = power(ok_vals); % power
		
		% calculate which in whcih time sectors
		if isempty(gen_opts.time_sectors)
			sorted_sectors = true(length(xs),1);
		elseif strcmp(gen_opts.time_sectors,'four_sectors')
			[y d m h mins secs] = datevec(cell2mat({data(ok_vals).dates}));
			sorted_sectors = sort_by_sectors(h,[ 3, 9 ; 9, 15; 15, 21 ;21,3]);
		end			
			
		% run over requested time sectors		
		for m_count = [1:MLT_count]
			
			% now do whatever you want here using xs,ys,this_f,fcount,pl_rows,pl_cols
			for_fn = [];
			for_fn.hf = figure(1); % what figure I want you to have
			for_fn.xs = xs(sorted_sectors(:,m_count));
			for_fn.ys = ys(sorted_sectors(:,m_count));
			for_fn.freqs = freqs;
			for_fn.this_f = this_f;
			for_fn.f_count = f_count;
			for_fn.pl_rows = pl_rows;
			for_fn.pl_cols = pl_cols; 
			for_fn.gen_opts = gen_opts; for_fn.freq_opts = freq_opts; for_fn.nbins = nbins;
			
			this_hf(m_count) = figure(m_count);
			for_fn.sector = [m_count]; for_fn.hf = this_hf(m_count);
			for_fn.figs = [1:MLT_count];
			
			
			% add on bits if necessary - extra info and any output between rolls
			if ~isempty(extras)
				for_fn.extras = extras;
			end
			if ~isempty(output_struct)
				for_fn.prev_output = output_struct;
				if m_count > 1
					error('Not built output to deal with this yet');
				end
			end
			
			[output_struct] = fn_to_do(for_fn);
				
			
			if false & ~isempty(gen_opts.time_sectors) & ishandle(m_count) & findobj(m_count,'type','figure')==m_count
				figure(m_count);
				figure('Name',sprintf('MLT sector %f',m_count));
			end
		
		end
	end
	
	if strcmp(gen_opts.time_sectors,'four_sectors') & numfreqs == 1%plot all on one plot
		
		for m_count = [1:4]
			figure(m_count);
			temp_title = get(gca,'title');
			temp_title = get(temp_title,'String');

			if length(temp_title)<11 | ~strcmp(temp_title(length(temp_title)-11:length(temp_title)-2),'MLT sector')
				new_title = strcat(temp_title,sprintf(' MLT sector %d',m_count'));
				title(new_title);
			end
			h_all(m_count) = gcf;
		end
		
		figs2subplots(h_all,[2 2]);
		
	end
	
	
end