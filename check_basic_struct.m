% Any checks you want to do

function [] = check_basic_struct( checking , st_type )


	if ~isstruct(checking)
		error('check_basic_struct:NotAStruct','didnt even give in a struct to check!');
	end


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
				elseif length(num_quants) ~= 1 | length(which_quants) > (num_quants+1) | max(which_quants) > (num_quants+1)
					error('check_basic_struct:BadInputSizeOrValue','first input should be number of quantiles, second which ones to use');
				end
				
				clearvars('temp_field','num_quants','which_quants');
				
			end
					
		end
	
	elseif strcmp(st_type,'gen_opts_1')
		% you need to do the rest of them!
		% what do I expect for time_sectors option??
		
		if ~isfield(checking,'coord') | ~isfield(checking,'f_lim') | ~isfield(checking,'pop_lim')...
				| ~isfield(checking,'time_sectors') | ~isfield(checking,'all_selections')
			error('check_basic_struct:BadFields','unexpected fields found');
		else
		% check the quantile_selections field
			check_basic_struct(checking.all_selections,'quantile_selections');
		end
		
					
	elseif strcmp(st_type,'quantile_selections')
		% are you testing each of these checks?
		if ~isstruct(checking) 
			error('check_basic_struct:BadInputType','need struct for options');
		end
		if length(fieldnames(checking)) ~= 3
			error('check_basic_struct:BadFields','unexpected number of fields');
		end

		% check we have expected fields
		if ~isfield(checking,'o_f') | ~isfield(checking,'num_quants') | ~isfield(checking,'which_quants')
			error('check_basic_struct:BadFields','unexpected fields found');
		end

		% now check contents
		for c_count = 1:length(checking)
			if isempty(checking(c_count).o_f) | isempty(checking(c_count).num_quants) | isempty(checking(c_count).which_quants)
				error('check_basic_struct:EmptyFields','whey are you handing in empty fields??');
			elseif ~isstr(checking(c_count).o_f)
				error('check_basic_struct:BadInputType','bad opitions');
			elseif ~isfloat(checking(c_count).num_quants) | length(checking(c_count).num_quants)~=1
				error('check_basic_struct:BadInputType','bad opitions');
			elseif ~isfloat(checking(c_count).which_quants) | max(checking(c_count).which_quants) > (checking(c_count).num_quants+1) | length(checking(c_count).which_quants) > (checking(c_count).num_quants+1)
				error('check_basic_struct:BadInputType','bad opitions');
			end
		end

		% and check no repeated fields
		all_fields = {checking.o_f};
		if length(unique(all_fields)) ~= length(checking)
			error('check_basic_struct:BadInput','repeated data field conditions');
		end	
		
	elseif strcmp(st_type,'add_omni_extras')
	% check each field is logical and corresponds to a funciton
		fnames = fieldnames(checking);
		
		if length(checking) > 1
			error('check_basic_struct:BadInputSIze',' expect struct of length 1 an dmany fields');
		end
		
		for f_count = 1:length(fnames)
			fn = fnames{f_count};
			
			if ~islogical(checking(1).(fn))
				error('check_basic_struct:BadInputType',' expect a logical here');
			elseif exist(sprintf('add_%s_field',fn)) ~= 2
				error('check_basic_struct:NoCorrespondingFunction',' you need a function to actually add the field %s ',fn);
			end
		end
	

	else 
		error('>>Unknown struct type<<');
	end
	
	
end
		
