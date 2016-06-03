% Plots the intensity map of teh omni field data and the power

function [output] = guts_plot_power_ofield_scatter( fn_st )
	
	output = [];
	
	figure(1);
	subplot(fn_st.pl_rows,fn_st.pl_cols,fn_st.f_count);
	
	% get the histogram with log scale for power
	[n,xedges,yedges,xb,yb,n_flat,n1] = linloghist3(fn_st.xs,fn_st.ys,fn_st.nbins);
	
	h = pcolor(xb,yb,n1);
	h.ZData = ones(size(n1)) * -max(max(n));
	colormap(parula);
	cmap = colormap;
	cmap(1,:) = [1 1 1];
	colormap(cmap);
	shading flat;
	%axis(axis_lim);
	set(gca,'yscale','log');
	ylabel('Power');
	xlabel(fn_st.gen_opts.of);
	title(sprintf('Intensity map freq %f mHz',fn_st.this_f));
	view(0,90);
		
end