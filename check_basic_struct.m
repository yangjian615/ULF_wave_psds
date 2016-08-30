% Any checks you want to do

function [] = check_basic_struct( checking , st_type )

	%error('check_basic_struct:BadInputType','cell required for speed_sectors field');
	disp('You should be testing this functionality');

	err_str = sprintf('>>>%s struct is bad<<<',st_type);

	if strcmp(st_type	,'multifreq_opts')
		disp('Checking frequency options');
		warning('>>You should merge single freq and multi freqs<<');
		
		% Currently only one of three options is allowed:
		% a) single freq supplied and nfreq = 1
		% b) just nfreqs
		% c) nfreqs and multifreqs
		
		% To make it easier, require ALL fields, even if empty
		if ~isfield(checking,'single_freq') | ~isfield(checking,'nfreqs') | ~isfield(checking,'multi_freqs')
			warning('>> You could actually fix the struct here<<');
			disp(err_str);
			error('>>>Empty fields<<<');
		end
		
		
		% Check single freq option
		if ~isempty(checking.single_freq)
			if length(checking.single_freq) ~= 1
				error(err_str);
			end
			if isempty(checking.nfreqs) | checking.nfreqs ~= 1
				error(err_str);
			end
			if ~isempty(checking.multi_freqs)
				error(err_str);
			end
		% Check nfreqs option
		elseif ~isempty(checking.nfreqs) 
			if checking.nfreqs == 1 & isempty(checking.single_freq)
				error(err_str);
			end
			if ~isempty(checking.multi_freqs) & length(checking.multi_freqs) ~= checking.nfreqs
				error(err_str);
			end
		elseif ~isempty(checking.multi_freqs)
			% single freq already fully checkd
			if isempty(checking.nfreqs)
				error(err_str);
			elseif checking.nfreqs ~= length(checking.multi_freqs)
				error(err_str);
			end
		else
			error('Did you get an empty??');
		end
	elseif strcmp(st_type,'get_opts')
		% check all required fields specified and correct types. 
		if ~isfield(checking,'station') | ~isfield(checking,'y') | ~isfield(checking,'m') | ~isfield(checking,'win_mins')
			disp(checking);
			error('Incorrect fields');
		elseif ~isa(checking.station,'char') | isempty(checking.station) | length(checking.station) ~= 4
			disp(checking.station);
			error('Station is not good enough!');
		elseif ~isa(checking.y,'double') | isempty(checking.y)
			disp(checking.y);
			error('Bad years');
		elseif ~isa(checking.m,'double') | isempty(checking.m)
			disp(checking.m);
			error('Bad months');
		elseif ~isa(checking.win_mins,'double') | isempty(checking.win_mins)
			disp(checking.win_mins);
			error('Bad number of minutes in window');
		end
	elseif strcmp(st_type,'gen_opts')
		% you need to do the rest of them!
		% what do I expect for time_sectors option??
		if isfield(checking,'speed_sectors') & ~isempty(checking.speed_sectors)
			if ~iscell(checking.speed_sectors)
				error('check_basic_struct:BadInputType','cell required for speed_sectors field');
			elseif length(checking.speed_sectors) ~= 2
				error('check_basic_struct:BadInputSize','bad number of elements in speed_sectors cell');
			else
				temp_field = checking.speed_sectors;
				num_quants = cell2mat(temp_field(1));
				which_quants = cell2mat(temp_field(2));
				
				if ~isa(num_quants,'double') | ~isa(which_quants,'double')
					error('check_basic_struct:BadInputType','two double inputs needed');
				elseif length(num_quants) ~= 1 | length(which_quants) > num_quants | max(which_quants) > num_quants 
					error('check_basic_struct:BadInputSizeOrValue','first input should be number of quantiles, second which ones to use');
				end
				
				clearvars('temp_field','num_quants','which_quants');
				
			end
					
		end
			
		
	else 
		error('>>Unknown struct type<<');
	end
	
	
end
		