% Wrapper to generalise when running functions over frequencies and data selection by quantiles.
%
% For examples see functions
%
% If you want to use the output, it should all be in a struct. Otherwise you will need to supply an empty output fiedl :(
%
% Use new gen_opts1 which takes a data_selection struct
% 


function [output_struct] = wrapper_freq_time_data_sort( data, gen_opts1, freq_opts, extras, fn_to_do )

	ptag = get_ptag();
	do_print(ptag,2,'wrapper_freq_time_data_sort: entering fn');

	f_tol = 0.0001; % frequency tolerance
	do_print(ptag,2,sprintf('wrapper_freq_time_data_sort:freq tol is %d',f_tol));


	%you need to check you aren't sorting by speed twice!
	
	if isempty(gen_opts1)
		gen_opts1 = make_basic_struct('gen_opts_1');
	else 
		check_basic_struct(gen_opts1,'gen_opts_1');
	end
	if isempty(freq_opts)
		freq_opts = make_basic_struct('multifreq_opts');
	else
		check_basic_struct(freq_opts,'multifreq_opts');
	end
	
	coord = gen_opts1.coord;
	f_lim = gen_opts1.f_lim;
	power_lims = gen_opts1.pop_lim;
	all_selections = gen_opts1.all_selections;
	
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
			f_slices = get_sample_freqs(numfreqs,freqs,gen_opts1.f_lim);
		else
			f_slices = cell2mat({freq_opts.multi_freqs});
		end
	else 
		f_slices = sf;
	end

	
	[pl_rows,pl_cols] = picknumsubplots(numfreqs*length(all_selections));
	
	if ~isempty(gen_opts1.time_sectors)
		error('wrapper_freq_time_data_sort:NotYetCoded');
	end
	
	% % arrange MLT sector stuff
	% if ~isempty(gen_opts.time_sectors)
		% if strcmp(gen_opts.time_sectors,'four_sectors')
			% MLT_count = 4;
			% if numfreqs > 1
				% warning('You havent got multi MLT multi freqs working yet');
			% end
		% else
			% error('unknown MLT options');
		% end
	% else
		% MLT_count = 1;
	% end
	
	
	
	
	this_hf = [];
	for f_count = [1:numfreqs]
		this_f = f_slices(f_count);
		
		do_print(ptag,2,sprintf('wrapper_freq_time_data_sort: doing freq opt %d',f_count));
		
		
		power = cell2mat({data.(sprintf('%s%s',coord,'ps'))});
		power = power( abs(this_f - freqs) < f_tol ,:);
		
		
		ok_vals = (power >= power_lims(1)) & (power < power_lims(2));
		
		ok_data = data(ok_vals);

		
		% calculate which in whcih time sectors
		if isempty(gen_opts1.time_sectors)
			sorted_sectors = true(length(xs),1);
		elseif strcmp(gen_opts1.time_sectors,'four_sectors')
			[y d m h mins secs] = datevec(cell2mat({data(ok_vals).dates}));
			sorted_sectors = sort_by_sectors(h,[ 3, 9 ; 9, 15; 15, 21 ;21,3]);
		end			
		
		
		
		
			
		% run over requested time 	
		%for m_count = [1:MLT_count]
		
		
		% run over each quantile selection
		for ss_count = 1:length(all_selections)
			selections = all_selections{ss_count};
			
			do_print(ptag,2,sprintf('wrapper_freq_time_data_sort: doing selection %d',ss_count));
			
			
			selected_data = [];
			selected_data = select_quantiles(ok_data,selections);
		
			
			% now do whatever you want here
			% multiple figures need supporting. Currently this is ignored
			for_fn = [];
			%for_fn.hf = figure(1); % what figure I want you to have
			for_fn.data = selected_data; % still contains freqs 
			%for_fn.this_f = this_f;
			for_fn.f_count = f_count; % which freq iteration are we on
			for_fn.sel_num = ss_count; % which data selection iteration are we on
			%for_fn.pl_rows = pl_rows;
			%for_fn.pl_cols = pl_cols; 
			for_fn.gen_opts1 = gen_opts1; for_fn.freq_opts = freq_opts;
			
			%this_hf(m_count) = figure(m_count);
			%for_fn.sector = [this_sector]; for_fn.hf = this_hf(m_count);
			%for_fn.figs = [1:numfreqs*length(all_selections)];
			
			
			% add on bits if necessary - extra info and any output between rolls
			if ~isempty(extras)
				for_fn.extras = extras;
			end
			if ~isempty(output_struct)
				for_fn.prev_output = output_struct;
				% if m_count > 1
					% error('Not built output to deal with this yet');
				% end
			end
			
			[output_struct] = fn_to_do(for_fn);
				
			
			% if false & ~isempty(gen_opts1.time_sectors) & ishandle(m_count) & findobj(m_count,'type','figure')==m_count %some may be this_sector instead of m_count
				% figure(m_count);
				% figure('Name',sprintf('MLT sector %f',m_count));
			% end
			
			% add sector to title
			
			curr_title = get(gca,'title');
			titl_str = get(curr_title,'String');
			
			if ~strcmp(titl_str(end-14:end-2),'for selection ')
			
				new_title  = strcat(titl_str,sprintf(' for sector %d',this_sector));
				title(new_title);
			end
			
			
		
		end
	end
	
	% if strcmp(gen_opts.time_sectors,'four_sectors') & numfreqs == 1%plot all on one plot
		
		% for m_count = [1:4]
			% figure(m_count);
			% temp_title = get(gca,'title');
			% temp_title = get(temp_title,'String');

			% if length(temp_title)<11 | ~strcmp(temp_title(length(temp_title)-11:length(temp_title)-2),'MLT sector')
				% new_title = strcat(temp_title,sprintf(' MLT sector %d',m_count'));
				% title(new_title);
			% end
			% h_all(m_count) = gcf;
		% end
		
		% figs2subplots(h_all,[2 2]);
		
	% end
	
	
end