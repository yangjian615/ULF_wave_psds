

function [output] = guts_plot_norm_scatter_slice( fn_st )

	output = [];
	
	figure(1);
	subplot(fn_st.pl_rows,fn_st.pl_cols,fn_st.f_count);
	
	% get the histogram with log scale for power
	[n,xedges,yedges,xb,yb,n_flat,n1] = linloghist3(fn_st.xs,fn_st.ys,fn_st.nbins);
	
	[n_norm] = normalise_2d_hist_to_distn(n); 
	
	
	
	n_norm1 = n_norm';
	n_norm_flat = reshape(n_norm,[],1);
	
	
	h = pcolor(xb,yb,n_norm1);
	h.ZData = ones(size(n_norm1)) * -max(max(n_norm));
	colormap(parula);
	cmap = colormap;
	cmap(1,:) = [1 1 1];
	colormap(cmap);
	shading flat;
	set(gca,'yscale','log');
	ylabel('Power');
	xlabel(fn_st.gen_opts.of);
	title(sprintf('Intensity map freq %f mHz',fn_st.this_f));
	view(0,90);
	
	cb = colorbar('eastoutside');
	ylabel(cb,'Probability of data lying in bin');


end