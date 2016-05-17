
% If you want results for a single freq, hand it in, else we'll do several
% makes a histogram out of the scatter plot and normalises each SW slice/bins by the amounbt of data there
% to remove effects of more data in modearte values. Then divide by total count to get probability of each bin.
%
% As per Kellerman paper.
%
% Uses figures 1 and 2
%
% You can hand in a single freq, a number of freqs or neither.

function [] = norm_scatter_slice( use_data, sf,num_slices )


	coord = 'x';
	pop = 'ps';
	o_field = 'speed';
	f_lo = 0.9;
	f_hi = 15;
	n_max = 0;
	nbins = [50,40];
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

		vals = vals(ok_vals);
		data = data(ok_vals);
		
		[n,xbb,ybb,n1,xb,yb,n_flat,xedges,yedges] = linloghist3(cell2mat({data.(o_field)}),vals,nbins);
		
		
		if max(max(n)) > n_max
			n_max = max(max(n));
		end 
		
		
		
		set(0,'DefaultAxesColorOrder',parula(num_slices));
		
		n_norm = nan(size(n)); % where we'll put normalised data
		
		% normalise each SW bin slice
		for pl_count = [1:nbins(1)]
			norm_val = sum(n(pl_count,:));
			if norm_val>0
				n_norm(pl_count,:) = n(pl_count,:)/norm_val;
			else
				n_norm(pl_count,:) = n(pl_count,:);
			end
		end
		
		n_norm = n_norm/(sum(sum(n_norm))); % get probability of each bin by dividig by total no.counts
		
		
		figure(1);
		[pl1,pl2] = picknumsubplots(num_slices);
		subplot(pl1,pl2,sl_count);
		
		% make an intensity map of it
		n_norm1 = n_norm';
		n_norm1(size(n,2) + 1, size(n,1) + 1) = 0;
		n_norm_flat = reshape(n_norm,[],1);
		
		h = pcolor(xb,yb,n_norm1);
		h.ZData = ones(size(n_norm1)) * -max(max(n_norm));
		colormap(parula);
		cmap = colormap;
		cmap = rescale_colormap(parula,n_norm_flat(n_norm_flat~=0));
		%warning('>>>rescaling of colormap turned off, no toolbox<<<');
		cmap(1,:) = [1 1 1];
		colormap(gca,cmap);
		shading flat;
		set(gca,'yscale','log');
		view(0,90);
		if sl_count == length(f_slices)
			colorbar('east');
		end
	
		ax.XTickLabelRotation=45;
		title(sprintf('freq %.4f mHz',sf),'FontSize',8);
		
	
		% now a 3d histogram to help visualise
		figure(6);
		[pl1,pl2] = picknumsubplots(num_slices);
		subplot(pl1,pl2,sl_count);
		colormap(gca,cmap);
		b = bar3(n_norm); %at least this actually works!
		for k = [1:length(b)]
			zdata = b(k).ZData;
			b(k).CData = zdata;
			b(k).FaceColor = 'interp';
		end
		text(n(nbins(1),1),n(1,nbins(2)),max(max(n_norm)),num2str(sum(sum(n_norm))));
		ax = gca;
		
		% you need to pick say, six labels for each
		xvals = round(linspace(1,nbins(1)-1,5)); yvals = round(linspace(1,nbins(2)-1,5));
		ax.XTick = xvals;
		ax.YTick = yvals;
		ax.XTickLabel = sprintf('%1.e\n',yedges(yvals));
		ax.YTickLabel = sprintf('%3.f\n',xedges(xvals));
		
		
		title(sprintf('freq %.4f mHz',sf),'FontSize',8);
		
		
	
		
	end

		
	
end