% makes one of the basic structures used for handing around data

function [out_struct] = make_basic_struct(st_name)
	
	if ~isstr(st_name)
		error('Structure type needs to be a string');
	end
	
	
	out_struct = [];
	
	% gen_opts: Generic options for all of this!
	if strcmp(st_name,'gen_opts')
		out_struct.coord = 'x';
		%out_struct.pop = 'ps';
		out_struct.of = 'speed';
		out_struct.f_lim = [0.9,15];
		out_struct.pop_lim = [1e-5,1e11];%[0.7,1.5e5] for psd
		out_struct.of_lim = [-inf,inf];%[250,780];
		out_struct.time_sectors = []; %all data is option
	% multifreq_opts: single or multiple frequency options
	elseif strcmp(st_name,'multifreq_opts')
		out_struct.single_freq = [];
		out_struct.nfreqs = 4;
		out_struct.multi_freqs = [];
	% get_opts: for getting data
	elseif strcmp(st_name,'get_opts')
		out_struct.station = 'GILL';
		out_struct.y = [1990:2004];
		out_struct.m = [1:12];
		out_struct.win_mins = 60;
	end
	
end
	