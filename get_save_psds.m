
% Does the calculations for each month, then saves the PSD and omni data
% away. Does not return the frequency axis.

function [output_data] = get_save_psds( data, get_opts )
	
	ptag = get_ptag();
	do_print(ptag,2,'get_save_psds: entering function\n');
	
	win_mins = get_opts.win_mins;
	
	% get f_res for the psds
	N = length( cell2mat({data(1).x}) );
	time_temp = data(1).times;
	time1 = time_temp(1);
	time2 = time_temp(2);
	t_res = abs(etime(datevec(time1),datevec(time2))); % in seconds
	f_res = 1/(N*t_res);
	
	freqs = [];

	s_size = size(data);
	
	get_psds =  {'x','y','z'};
	for ps_ind = 1:length(get_psds)
		ps_coord = get_psds{ps_ind};
		to_calc = cell2mat({data.(ps_coord)});
		[pxx,freqs] = calculate_multitaper_powerspectrum(to_calc,t_res);
			
		if ps_ind == 1
			mat_freqs = repmat(freqs,1,size(pxx,2));
			c_freqs = mat2cell(mat_freqs,size(pxx,1),ones(1,size(pxx,2)));
			[data(:).freqs] = c_freqs{:};
		end
		
		c_pxx = mat2cell(pxx,size(pxx,1),ones(1,size(pxx,2)));
		[data(:).(sprintf('%sps',ps_coord))] = c_pxx{:};
		
	end
	
	
	output_data = data;

end