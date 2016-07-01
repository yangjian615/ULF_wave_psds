% uses function to fit a straight line to top of scatter data (ratio of data below can be specified)
% does for each freq at each station listed over all years
% plots it

% built from old plot_speed_power_upper_bounds
% only really made for speed atm

% You need to hand in all freqs atm, this should be fixed.

function [] = plot_speed_power_upper_bounds(data, gen_opts,ratio )


	if isempty(gen_opts)
		gen_opts = make_basic_struct('gen_opts');
	elseif ~strcmp(gen_opts.of,'speed') 
		error('Only made for speed');
	end
	
	
	
	extras = [];
	extras.ratio = ratio;
	
	% currently want to run over all freqs so set this up
	%freqs = calcfreqs(cell2mat({data(1).x}),data(1).times,[] );
	freqs = data(1).freqs*1e3;
	freqs = freqs( freqs >= gen_opts.f_lim(1) & freqs <= gen_opts.f_lim(2) );
	freq_opts = [];
	freq_opts.single_freq = []; freq_opts.nfreqs = length(freqs); freq_opts.multi_freqs = freqs;
	
	
	wrapper_power_ofield_scatter(data,gen_opts,freq_opts,[],extras,@guts_plot_speed_power_upper_bounds);
	

end