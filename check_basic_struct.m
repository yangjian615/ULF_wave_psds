% Any checks you want to do

function [] = check_basic_struct( checking, st_type )

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
	else 
		error('>>Unknown struct type<<');
	end
	
	
end
		