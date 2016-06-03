
function [output] = guts_plot_mean_var_scatter_slice_normal_fits( fn_st )

	output = [];

	ys = log(fn_st.ys); % power
	
	% get the histogram with log scale for power
	[n,xedges,yedges,xb,yb,n_flat,n1] = linlinhist3(fn_st.xs,ys,fn_st.nbins);
	
	% normalise by amount of omni field data and overall data count to get occurrence distn
	[temp,n_norm] = normalise_2d_hist_to_distn(n); % we are only interested in each slice so area under each is 1
	
	% so we are now interested in n_norm(index,:) for each bin
	mean_stds = nan(2,size(n_norm,1));
	
	figure(1);
	set(0,'DefaultAxesColorOrder',parula(fn_st.nbins(1)));
	for test_count = [1:size(n_norm,1)]
		if sum(n_norm(test_count,:)) > 0
			subplot(fn_st.pl_rows,fn_st.pl_cols,fn_st.f_count); title(sprintf('occurrence distns and fitted normal for freq %f mHz',fn_st.this_f));
			set(gca,'ColorOrderIndex',test_count); 
			plot(yedges,n_norm(test_count,:)); hold on;
			
			%disp(trapz(n_norm(test_count,:))); % for checking total prob
			
			%fit a normal distn to it
			temp_freqs = n(test_count,:);
			pd = fitdist(yedges','Normal','frequency',temp_freqs);
			pdf_ys = pdf(pd,yedges);
			pdf_ys = pdf_ys / (trapz(pdf(pd,yedges)));
			plot(yedges,pdf_ys,'r'); hold on;
			%disp(trapz(pdf_ys));
			
			
			mean_stds(:,test_count ) = [pd.mu,pd.sigma];
			
		end
		
	end
	
	figure(2);
	subplot(fn_st.pl_rows,fn_st.pl_cols,fn_st.f_count); 
	set(0,'DefaultAxesColorOrder',parula(fn_st.nbins(1)));
	for pl_count = [1:length(mean_stds)]
		set(gca,'ColorOrderIndex',pl_count); 
		scatter(mean_stds(1,pl_count),mean_stds(2,pl_count),7,'filled'); hold on;
	end
	axis([-5,11,1.5,2.5]);
	xlabel('Mean, log(power)');
	ylabel('St dev, log(power)');
	title(sprintf('mean vs std dev of fitted distns, freq %f mHz',fn_st.this_f));
	
	% mke the legend - find centre of SW speed bins
	bin_speeds = {};
	for b_count = [1:length(xedges)-1]
		bin_speeds{b_count} = sprintf('%3.0f km s^{-1}', mean(xedges(b_count:b_count+1)));
	end	
	%legend(bin_speeds);
	
	
	
end
