% Plots the intensity map of teh omni field data and the power

function [output] = guts_plot_power_ofield_scatter( fn_st )
	
	output = [];

	figure(fn_st.hf);
	%fignum = fn_st.sector;
	%figure(fignum);
	subplot(fn_st.pl_rows,fn_st.pl_cols,fn_st.f_count);
	% get the histogram with log scale for power
	[n,xedges,yedges] = linloghist3(fn_st.xs,fn_st.ys,fn_st.nbins);
	
	
	%% See guts_plot_norm_scatter_slice for pcolor options. We dont interpolate here - would look nicer
	%% but doesn't show up the outliers.
	[xb,yb] = meshgrid(xedges,yedges);
	n(fn_st.nbins(1)+1,:) = 0; n(:,fn_st.nbins(2)+1) = 0;
	
	
	h = pcolor(xb,yb,n');
	h.ZData = ones(size(n')) * -max(max(n));
	colormap(parula);
	%cmap = rescale_colormap(colormap,n_flat);
	%disp('rescaling cmap');
	cmap = colormap;
	cmap(1,:) = [1 1 1];
	colormap(cmap);
	shading flat;
	
	if fn_st.gen_opts.of_lim(1) ~= -inf & fn_st.gen_opts.of_lim(2) ~= inf %if we are supplying options, use them!
		axis([fn_st.gen_opts.of_lim(1),fn_st.gen_opts.of_lim(2),1e-3,1e7]);
	elseif strcmp(fn_st.gen_opts.of,'speed')
		axis([200,850,1e-3,1e7]);
	else
		axis([-inf,inf,1e-3,1e7]);
	end
	
	set(gca,'yscale','log');
	ylabel('PSD, (nT)^2 / (mHz)');
	x_str = ofield_axis_label(fn_st.gen_opts.of);
	xlabel(x_str);
	title(sprintf('freq %f mHz',fn_st.this_f));
	view(0,90);
	
	colorbar('eastoutside');
	
	
		
end