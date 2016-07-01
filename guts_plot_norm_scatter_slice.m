

function [output] = guts_plot_norm_scatter_slice( fn_st )

	output = [];
	fignum = fn_st.sector;
	figure(fignum);
	subplot(fn_st.pl_rows,fn_st.pl_cols,fn_st.f_count);
	
	% get the histogram with log scale for power
	[n,xedges,yedges] = linloghist3(fn_st.xs,fn_st.ys,fn_st.nbins);
	ycentres = lin_edges_to_mids(yedges);
	xcentres = lin_edges_to_mids(xedges);
	
	[n_norm] = normalise_2d_hist_to_distn(n); 
	
	
	
	n_norm1 = n_norm';
	n_norm_flat = reshape(n_norm,[],1);
	
	%% Note: To use shading flat (ie clear bins) they will be offset. If not you should use 
	%% shading interp. Either way you have to add in the zeroes or it fill throw away actual data. See document in Notes Collection.
	%% 
	%% Option 1: Coloured bins. Use pcolor with shading flat or default. Colour of bin is selected by bottom left corner
	%% so you should add the row & col of zeroes then supply the edges of the bins.
	%%
	%% Option 2: Interpolated smooth colour. Use pcolor with shading interp. It won't throw away your data 
	%% this time but it will only colour up the first/last points given. You should give it a mesh made from 
	%% bin centres and your real data with no added zeroes.
	%%
	%% eg Option 1: [xb,yb] = meshgrid(xedges,yedges); 
	%%				n_norm1(fn_st.nbins(2)+1,:) = 0; n_norm1(:,fn_st.nbins(1)+1) = 0; 
	%%				h = pcolor(xb,yb,n_norm1);
	%%				shading flat
	%%
	%% eg Option 2: [xb,yb] = meshgrid(xcentres,ycentres); 
	%%				h = pcolor(xb,yb,n_norm1);
	%%				shading interp
	
	
	
	% add in zero row and col which pcolor will throw away.
	%n_norm1(fn_st.nbins(2)+1,:) = 0; n_norm1(:,fn_st.nbins(1)+1) = 0;
	%[xb,yb] = meshgrid(xedges,yedges);
	
	[xb,yb] = meshgrid(xcentres,ycentres);
	
	h = pcolor(xb,yb,n_norm1);
	h.ZData = ones(size(n_norm1)) * -max(max(n_norm));
	colormap(parula);
	%cmap = rescale_colormap(colormap,n_flat);
	%disp('rescaling');
	cmap = colormap;
	cmap(1,:) = [1 1 1];
	colormap(cmap);
	%shading flat;
	shading interp
	set(gca,'yscale','log');
	ylabel('PSD, (nT)^2 / (mHz)');
	x_str = ofield_axis_label(fn_st.gen_opts.of);
	xlabel(x_str);
	title(sprintf('freq %f mHz',fn_st.this_f));
	view(0,90);
	
	if fn_st.gen_opts.of_lim(1) ~= -inf & fn_st.gen_opts.of_lim(2) ~= inf %if we are supplying options, use them!
		axis([fn_st.gen_opts.of_lim(1),fn_st.gen_opts.of_lim(2),1e-3,1e8]);
	elseif strcmp(fn_st.gen_opts.of,'speed')
		axis([200,850,1e-3,1e8]);
	else
		axis([-inf,inf,1e-3,1e8]);
	end
	
	cb = colorbar('eastoutside');
	ylabel(cb,'Probability of data lying in bin');


end