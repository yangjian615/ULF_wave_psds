
% similar structurte to try_get_scatter_slice: you can hand in teh number of freqs
% you want to look at or a sinlge freq or neither

function [output] = guts_plot_scatter_and_slice_upper_bound( fn_st )

	output = [];
	
	fignum = fn_st.sector;
	figure(fignum);
	subplot(fn_st.pl_rows,fn_st.pl_cols,fn_st.f_count);

	ratio = fn_st.extras.ratio;
	
	
	if isempty(ratio)
		ratio = 0.98;
	end
	
	
	sf = fn_st.this_f;
	xs = fn_st.xs;
	ys = fn_st.ys;
	
	[n,xedges,yedges] = linloghist3(xs,ys,fn_st.nbins);
	%xcentres = lin_edges_to_mids(xedges); ycentres = exp( lin_edges_to_mids(log(yedges)) );
	
	for r_count = [1:length(ratio)]
		this_ratio = ratio(r_count);
		all_pars = nan(2,fn_st.nbins(1));
		for sp_count = [1:fn_st.nbins(1)]
			sp_lo = xedges(sp_count);
			sp_hi = xedges(sp_count+1);
			in_bin = xs >= sp_lo & xs < sp_hi;
			if sum(in_bin) > 5 %arbitrary number of points in slices
				%[par] = top_straight_line(xs(in_bin),log(ys(in_bin)),this_ratio);
				[par] = top_straight_line(log(ys(in_bin)),this_ratio);
				hold on;
				%plot([sp_lo sp_hi],[1 1]*exp(par),'r');
				all_pars(1,sp_count) = par;
				all_pars(2,sp_count) = (sp_lo+sp_hi)/2;
			end
		end
		
		plot(all_pars(2,:),exp(all_pars(1,:)),'r');
	end

		
	
end