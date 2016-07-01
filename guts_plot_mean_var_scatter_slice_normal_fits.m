
function [output] = guts_plot_mean_var_scatter_slice_normal_fits( fn_st )

	output = [];

	nfit_opts = fn_st.extras.nfit_opts; % should tell us whether to plot the slices, plot the mean-var scatter or qqplots.
	disp(sprintf('What you want to do with normal fits: %s',nfit_opts));
	ys = log(fn_st.ys); % power
	
	
	% get the histogram with log scale for power
	[n,xedges,yedges] = linlinhist3(fn_st.xs,ys,fn_st.nbins);
	ycentres = lin_edges_to_mids(yedges);
	xcentres = lin_edges_to_mids(xedges);
	
	
	% normalise by amount of omni field data and overall data count to get occurrence distn
	%[temp,n_norm] = normalise_2d_hist_to_distn(n); disp('Normalised so that area under each curve adds to 1'); % we are only interested in each slice so area under each is 1
	[n_norm] = normalise_2d_hist_to_distn(n); disp('Normalised so total area is 1'); % or whole prob whould add to 1
	
	
	% so we are now interested in n_norm(index,:) for each bin
	mean_stds = nan(2,size(n_norm,1));
	
	% add an extra subplot spot for legend in seconf plot
	pl_rows = fn_st.pl_rows; pl_cols = fn_st.pl_cols;
	[pl_rows2,pl_cols2] = picknumsubplots(fn_st.freq_opts.nfreqs+1);
	
	
	% Calculate the pdf to go with each
	fit_pdfs = []; 
	for test_count = [1:size(n_norm,1)]
		if sum(n_norm(test_count,:)) > 0
			
			temp_freqs = n(test_count,:);
			if sum(temp_freqs) > 1
				pd = fitdist(ycentres','Normal','frequency',temp_freqs);
				this_pdf = pdf(pd,ycentres);
				fit_pdfs(test_count).pd = pd;
				fit_pdfs(test_count).pdf = this_pdf;
				fit_pdfs(test_count).pdf_scaled =  this_pdf / (trapz(this_pdf));
				%plot(yedges,pdf_ys,'k-.'); hold on;
		
				
			end
		end
	end
	
	% on last time, make the legend  to use later- find centre of SW speed bins
	if fn_st.f_count == fn_st.freq_opts.nfreqs %show legend on last iteration in last subplot
		bin_speeds = {};
		%mean_for_leg = [];
		for b_count = [1:length(xcentres)]
			%mean_for_leg[b_count] = mean(xedges(b_count:b_count+1));
			if strcmp(fn_st.gen_opts.of,'speed')
				bin_speeds{b_count} = sprintf('%3.0f km s^{-1}', xcentres(b_count));
			elseif strcmp(fn_st.gen_opts.of,'Np')
				bin_speeds{b_count} = sprintf('%3.0f N cm^{-3}', xcentres(b_count));
			end
		end		
	end
	
	
	if strcmp(nfit_opts,'plot_fits');
	%% Option 1: Plot the slices and fits.
		fignum = fn_st.sector;
		figure(fignum);
		set(0,'DefaultAxesColorOrder',summer(fn_st.nbins(1)));
		for test_count = [1:size(n_norm,1)]
			if ~isempty(fit_pdfs(test_count).pdf)%sum(n_norm(test_count,:)) > 0
				subplot(pl_rows,pl_cols,fn_st.f_count); title(sprintf('occurrence distns and fitted normal for freq %f mHz',fn_st.this_f));
				set(gca,'ColorOrderIndex',test_count); 
				%plot(yedges,n_norm(test_count,:)); hold on; % with power still in logs, to compare pdf
				plot(exp(ycentres),n_norm(test_count,:)); hold on; set(gca,'xscale','log');

				
				disp(trapz(n_norm(test_count,:))); % for checking total prob
				
				pdf_ys = fit_pdfs(test_count).pdf_scaled;
				%plot(yedges,pdf_ys,'k-.'); hold on;
			else	
				disp('Empty pdf?');

				
			end
			
		end
		if fn_st.f_count == fn_st.freq_opts.nfreqs %show legend on last iteration in last subplot
			legend(bin_speeds,'Location','east');
		end
	elseif strcmp(nfit_opts,'mv_scatter')	
	%% Option 2: plot mean vs scatter of each
		fignum = fn_st.sector;
		figure(fignum);
		subplot(pl_rows2,pl_cols2,fn_st.f_count); 
		set(0,'DefaultAxesColorOrder',parula(fn_st.nbins(1)));
		for pl_count = [1:length(fit_pdfs)]
			set(gca,'ColorOrderIndex',pl_count); 
			if ~isempty(fit_pdfs(pl_count).pd)
				scatter(fit_pdfs(pl_count).pd.mu,fit_pdfs(pl_count).pd.sigma,7,'filled'); hold on;
			else
				disp('Empty pdfs??');
			end
		end
		
		%if strcmp(fn_st.gen_opts.of,'speed')
			%axis([-5,11,1.5,2.5]);
		%elseif strcmp(fn_st.gen_opts.of,'Np')
		%end
		xlabel('Mean, log(power)');
		ylabel('St dev, log(power)');
		title(sprintf('mean vs std dev of fitted distns, freq %f mHz',fn_st.this_f));
		
		% make the legend  to use later- find centre of SW speed bins
		if fn_st.f_count == fn_st.freq_opts.nfreqs %show legend on last iteration in last subplot
			subplot(pl_rows2,pl_cols2,fn_st.f_count+1); 
			set(0,'DefaultAxesColorOrder',parula(fn_st.nbins(1)));
			
			
			%legend(bin_speeds,'Location','east');
			for b_count = [1:length(bin_speeds)]
				set(gca,'ColorOrderIndex',b_count); 
				scatter(1.5,b_count,20,'filled'); hold on;
				text(2,b_count,bin_speeds{b_count});
			end
			axis([1,5,0,length(bin_speeds)+1]);
			axis off;

		end
	elseif strcmp(nfit_opts,'qqplots')
		fignum = fn_st.sector;
		figure(fignum);
		subplot(pl_rows,pl_cols,fn_st.f_count); 
		set(0,'DefaultAxesColorOrder',parula(fn_st.nbins(1)));
		for pl_count = [1:length(fit_pdfs)]
			
			% sort out correct colouring
			set(gca,'ColorOrderIndex',pl_count); 
			all_col = get(gca,'ColorOrder');
			this_col = all_col(pl_count,:);
			
			if ~isempty(fit_pdfs(pl_count).pd)
				hold on;
				hq = qqplot(sort(n_norm(pl_count,:)),fit_pdfs(pl_count).pdf_scaled);
				warning('>Not sure these options are right yet, check you indices<');
				
				
				% returns a 3x1 vector hq, hq(1) is the handle to the symbols
				% hq(2) is the handle to the solid portion of the line
				% and hq(3) to the dashed line

				% for example
				set(hq(1),'marker','o','markerfacecolor',this_col,'markersize',2.5,'markeredgecolor',this_col);
				set(hq(2),'linewidth',1,'color',this_col);
				set(hq(3),'linewidth',1,'color',this_col);
			end
		end
	else
		error('Unknown option what to do with normal fits!');
	end
	
	
	
	
end
