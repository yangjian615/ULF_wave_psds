
% similar structurte to try_get_scatter_slice: you can hand in teh number of freqs
% you want to look at or a sinlge freq or neither

function [] = plot_scatter_and_slice_upper_bound( use_data, sf, num_freqs,ratio )

	coord = 'x';
	pop = 'ps';
	o_field = 'speed';
	f_lo = 0.9;
	f_hi = 15;
	nbins = [50,40];
	data = use_data;
	n_max = 0.9e9;
	sc_col = [7 144 203] ./ 255;
	
	freqs = calcfreqs(cell2mat({data(1).x}),data(1).times,[] );
	
	if isempty(ratio)
		ratio = 0.98;
	end
	if isempty(num_freqs)
		if isempty(sf)
			num_freqs = 4;
		else
			num_freqs=1;
		end
	end
	
	if isempty(sf)
		f_slices = quantile(linspace(f_lo,f_hi,100),num_freqs);
	
		% find freqs you want to do slices of
		for sl_count = [1:length(f_slices)]
			closest_val = min(abs(freqs - f_slices(sl_count)));
			closest_ind = find( abs(freqs - f_slices(sl_count)) == closest_val) ;
			f_slices(sl_count) = freqs(closest_ind);
		end
	else
		f_slices = [sf];
	end
	
	
	for sl_count = [1:length(f_slices)]
		sf = f_slices(sl_count);
		vals = cell2mat({data.(sprintf('%s%s',coord,pop))});
		vals = vals(freqs == sf, :);
		
		power_lims = [1e-5,1e11];%[0.7,1.5e5]; %ONLY SET FOR PSDs, NOT THE POWER SPECTRA
		ok_vals = (vals >= power_lims(1)) & (vals < power_lims(2));

		xs = cell2mat({data(ok_vals).(o_field)});
		ys = vals(ok_vals);
		
		figure(1);
		[pl1,pl2] = picknumsubplots(num_freqs);
		subplot(pl1,pl2,sl_count);
		
		scatter(xs,ys,7,sc_col,'.'); hold on;
		set(gca,'yscale','log');
		
		% now calculate and add upper bound for each slices
		
		[n,xbb,ybb,n1,xb,yb,n_flat,xedges,yedges] = linloghist3(cell2mat({data.(o_field)}),vals,nbins);
		
		for sp_count = [1:nbins(1)]
			sp_lo = xbb(sp_count);
			sp_hi = xbb(sp_count+1);
			in_bin = xs >= sp_lo & xs < sp_hi;
			if sum(in_bin) > 5 %arbitrary number of points in slices
				[par] = top_straight_line(xs(in_bin),log(ys(in_bin)),ratio);
				plot([sp_lo sp_hi],[1 1]*exp(par),'r');
			end
		end
		
		title(sprintf('freq %.2f mHz',sf));
		axis([min(xs),max(xs),0,n_max]);
		
		
	end

		
	
end