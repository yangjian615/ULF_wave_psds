
% If you want results for a single freq, hand it in, else we'll do several


% Work points: alldistfit, goodness of fit (chi2gof? ), box and  whisker plots, POisson distn!! qq plot
% Final code into: norm_scatter_slice (Normalised by amount in each SW slice) and get_scatter_slice_distn (plot of the count in each)

function [] = get_scatter_slice_distn( use_data, sf,num_slices )

	do_plot = true;

	coord = 'x';
	pop = 'ps';
	o_field = 'speed';
	f_lo = 0.9;
	f_hi = 15;
	n_max = 0;
	nbins = [50,40]; % that we use to count data in. One will be log separated
	data = use_data;
	
	freqs = calcfreqs(cell2mat({data(1).x}),data(1).times,[] );
	
	if isempty(num_slices)
		if isempty(sf)
			num_slices = 4;
		else
			num_slices=1;
		end
	end
	
	if isempty(sf)
		f_slices = quantile(linspace(f_lo,f_hi,100),num_slices);
	
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

		xs = cell2mat({data(ok_vals).(o_field)}); %eg SW speed
		ys = vals(ok_vals); % power
		
		[n,xbb,ybb,n1,xb,yb,n_flat,xedges,yedges] = linloghist3(xs,ys,nbins);
		
		
		if max(max(n)) > n_max
			n_max = max(max(n));
		end 
		

		set(0,'DefaultAxesColorOrder',parula(num_slices));
		if do_plot
			for pl_count = [1:nbins(1)]
				figure(1);
				subplot(5,ceil(nbins(1)/5),pl_count);
				set(gca,'ColorOrderIndex',sl_count); %want the colour to jump if some freqs not plotted
				plot(ybb(1:nbins(2)),n(pl_count,:)); hold on;
				if sl_count == num_slices % do labelling on last run
					axis([min(ybb),max(ybb),0,n_max]);
					text(0.01*(max(ybb)-min(ybb)),0.9*n_max,sprintf('%.0f km s^{-1}',xbb(pl_count)),'FontSize',8);
					set(gca,'xscale','log');
				end
			end
			for pl_count = [1:nbins(2)]
				figure(2);
				subplot(5,ceil(nbins(2)/5),pl_count);
				%ys = n(:,pl_count);
				%xs = xbb(1:nbins(1));
				set(gca,'ColorOrderIndex',sl_count); %want the colour to jump if some freqs not plotted
				plot(xbb(1:nbins(1)),n(:,pl_count)); hold on;
				if sl_count == num_slices
					text(0.5*(max(xbb)-min(xbb)),0.9*n_max,sprintf('%.2e (nT)^2',ybb(pl_count)),'FontSize',8);
					axis([min(xbb),max(xbb),0,n_max]);
				end	
			end
			legend(num2str(f_slices'));
		end	
	end

		
	
end