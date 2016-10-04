% Wrapper to generalise when running functions over frequencies for omni field scatter data. 
% For examples see functions plot_mean_var_scatter_slice_normal_fits OR plot_power_ofield_scatter
%
% If you want to use the output, it should all be in a struct. Otherwise you will need to supply an empty output fiedl :(
%
% Also deals with MLT separations
% This expects you to want to plot aganist something that is NOT frequency - you need a different way to put this on xaxis.
%
% This is the wrapper you should use for functions that look at a single field and performa analysis on this, ie the x-axis 
% will be one of the OMNI fields. Use a different function wrapper if you want to plot anythin against frequency.

function [output_struct] = wrapper_power_ofield_scatter( data, gen_opts, freq_opts, nbins, extras, fn_to_do )

	ptag = get_ptag();

	f_tol = 0.0001; % frequency tolerance
	do_print(ptag,2,sprintf('freq tol is %d',f_tol));


	%you need to check you aren't sorting by speed twice!
	
	if isempty(gen_opts)
		gen_opts = make_basic_struct('gen_opts');
	else 
		check_basic_struct(gen_opts,'gen_opts');
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
	
	if ~isempty(gen_opts.time_sectors) & ~isempty(gen_opts.speed_sectors)
		error('wrapper_power_ofield_scatter:NotYetCoded');
	end
	
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
	
	
	
	% arrange speed sector stuff. For now just hijack MLT stuff
	if ~isempty(gen_opts.speed_sectors)
		num_speed_quants = cell2mat(gen_opts.speed_sectors(1));
		which_speed_quants = cell2mat(gen_opts.speed_sectors(2));
		
		MLT_count = length(which_speed_quants);
		do_print(ptag,2,'wrapper_power_ofield_scatter:sorting by speed sector\n');
		if numfreqs >1 
			error('wrapper_power_ofield_scatter:NotYetCoded','case not written yet');
		end
	end
	
	this_hf = [];
	for f_count = [1:numfreqs]
		this_f = f_slices(f_count);
		
		
		power = cell2mat({data.(sprintf('%s%s',coord,'ps'))});
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
		
		% calculate in which soeed sectors
		if ~isempty(gen_opts.speed_sectors)
			[speed_quants,sorted_sectors] = sort_by_speed_sectors(cell2mat({data(ok_vals).speed}),num_speed_quants);
		end
		
		
		% maybe function here to select correct stuff each time??
			
		% run over requested time OR speed sectors		
		for m_count = [1:MLT_count]
			
			if ~isempty(gen_opts.speed_sectors) %m_count won't necessarily mathc up with number of sector
				this_sector = which_speed_quants(m_count);
			else 
				this_sector = m_count;
			end
			
			in_this_sector = sorted_sectors == this_sector;
			
			% now do whatever you want here using xs,ys,this_f,fcount,pl_rows,pl_cols
			for_fn = [];
			for_fn.hf = figure(1); % what figure I want you to have
			for_fn.xs = xs(in_this_sector);%xs(sorted_sectors(:,m_count));
			for_fn.ys = ys(in_this_sector); %ys(sorted_sectors(:,m_count));
			for_fn.freqs = freqs;
			for_fn.this_f = this_f;
			for_fn.f_count = f_count;
			for_fn.pl_rows = pl_rows;
			for_fn.pl_cols = pl_cols; 
			for_fn.gen_opts = gen_opts; for_fn.freq_opts = freq_opts; for_fn.nbins = nbins;
			
			this_hf(m_count) = figure(m_count);
			for_fn.sector = [this_sector]; for_fn.hf = this_hf(m_count);
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
				
			
			if false & ~isempty(gen_opts.time_sectors) & ishandle(m_count) & findobj(m_count,'type','figure')==m_count %some may be this_sector instead of m_count
				figure(m_count);
				figure('Name',sprintf('MLT sector %f',m_count));
			end
			
			% add sector to title
			if ~isempty(gen_opts.speed_sectors)
				curr_title = get(gca,'title');
				titl_str = get(curr_title,'String');
				
				if ~strcmp(titl_str(end-11:end-2),'for sector')
				
					new_title  = strcat(titl_str,sprintf(' for sector %d',this_sector));
					title(new_title);
				end
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