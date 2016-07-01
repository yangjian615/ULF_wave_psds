% uses function to fit a straight line to top of scatter data (ratio of data below can be specified)
% does for each freq at each station listed over all years
% plots it

% This ew version doesn't save the plot


function [output] = guts_plot_speed_power_upper_bounds( fn_st )

	output = [];
	
	
	if isfield(fn_st,'prev_output')
		top_pars = fn_st.prev_output.top_pars;
	else 
		top_pars = nan(1,fn_st.freq_opts.nfreqs);
	end
		
	ratio = fn_st.extras.ratio;
	if isempty(ratio) | abs(ratio -1) > 1
		ratio = 0.98;
	end
						
					
	[par] = top_straight_line(log(fn_st.ys),ratio);
	top_pars(fn_st.f_count) = par;		
	output.top_pars = top_pars;
	
	% plot on last freq iteration
	if fn_st.f_count == fn_st.freq_opts.nfreqs
		figure(1);
		%set(gcf,'numbertitle','off','name',sprintf('upper bounds for MLT sector %d',mlt_bin));
		plot(cell2mat({fn_st.freq_opts.multi_freqs}),exp(top_pars),'.-'); hold on;
			
			%legend(stations);
		set(gca,'yscale','log');
		ylabel('PSD upper limit, (nT)${}^{2}$/(mHz)');
		xlabel('Freq, mHz');
		%title(sprintf('%s coordinate',coord));
		%axis([-inf,inf,min(min(min(min(tops)))),max(max(max(max(tops))))]);
			
		
	end
end