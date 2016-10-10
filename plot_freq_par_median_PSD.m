% Takes 2 parameters, takes as many quantiles of each and plots the median PSD at the given frequency
% par1,2 should be string s of field, numq1,2, integers adn whichfreq in mHz
% numq2 is number of bions to sort into whether using quatnile or linspace methods

function [res] = plot_freq_par_median_PSD( data, par2, numq2, num_conts, freq_lim, extra )

	coord = 'x'; % youll want to feed this in a t some point
	use_quantile_ticks = false;
	
	ptag = get_ptag();
	do_print(ptag,2,'plot_freq_par_median_PSD:entering fn \n');

	
	
	% first get the frequency
	freqs = data(1).freqs;%*1e3;
	
	% only use freqs larger than 1mHz
	if isempty(freq_lim)
		freq_lim = [1,15]*1e-3;
	end
		
	use_freqs = freqs >= freq_lim(1) & freqs <= freq_lim(2);
	freqs = freqs(use_freqs);
	
	

	% make selection strcut 
	data_selection = [];
	data_selection(1).o_f = par2;
	data_selection(1).num_quants = numq2; 
	
	% initialise results matrix
	res  = nan(length(freqs),numq2);
	tot = nan(length(freqs),numq2); % so we know amount used
	extras = nan(length(freqs),numq2);
	bin_centres2 = nan(1,length(numq2));
	
	% remove data wtith unphyscial PSD values, same as whebn using wrapper fns. Use default values, don't bother to hand in.
	temp_gopts =make_basic_struct('gen_opts');
	
	% get lists of which  quantile data lies in for each par
	[quants2,which_q2] = sort_by_speed_sectors(cell2mat({data.(par2)}),numq2);
	
	

	
	for q2 = 1:numq2
		
		
		%get data selected
		% you may need to speed this up by getting indices instead of passing out stuff
		% this is so slow as it recalculates EVERY time. Surely you only need to do once? Different function?
		%selected_data = select_quantiles(data,data_selection);
		
		in_q = which_q2==q2;
		bin_centres2(q2) = median( cell2mat({data( which_q2 == q2 ).(par2)}) );
		
		if isnan(bin_centres2(q2))
			bin_centres2(q2) = mean( [quants2(q2),quants2(q2+1)] );
		end
		
		if sum(in_q) > 0
			selected_data = data( in_q );
			all_pow = cell2mat({selected_data.(sprintf('%sps',coord))});
			all_pow = all_pow(use_freqs,:);
			
			
			do_print(ptag,3,sprintf('plot_freq_par_median_PSD: for q %d : %d used for median \n',q2,size(all_pow,2)));
			
			
			extras(:,q2) = median( cell2mat({selected_data.speed}) );
			res(:,q2) = median(all_pow,2);
		else 
			do_print(ptag,2,sprintf('plot_freq_par_median_PSD: No data for case of bin number %d \n',q2));
			res(:,q2) = 0;
		end
		
		
	end
	
	% check output
	if sum(sum(isnan(res))) > 0  
		error('plot_freq_par_median_PSD:BadResult','got nans still1 in output');
	elseif sum(isnan(bin_centres2)) > 0
		error('plot_freq_par_median_PSD:BadResult','got nans still in bin centres');
	end
	
	
	% get blank space for zero values
	cmap = colormap;
	if min(min(res)) == 0 
		cmap(1,:) = [1 1 1];
	end
	colormap(cmap);	% how much are we cutting out??
	
	%plot it. Use log to mess with colorbar
	x_axis = 1:numq2+1; % by quantile 
	x_axis = bin_centres2; % by value of quantile bin
	[xb,yb] = meshgrid(x_axis,freqs);
	warning('plot_freq_par_median_PSD:meshgrid seems to be abakwards but you should really check this');
	
	% two loops one for pcolor and conotour, one for whatever you want?
	for f_count = 1:3
		figure(f_count);
		if f_count ==1 
			h = pcolor(xb,yb,log(res));
			shading flat
			%shading interp
			hold on;
			if isempty(num_conts)
				contour(x_axis,freqs,log(res),'k');	
			else
				contour(x_axis,freqs,log(res),num_conts,'k');
			end
			
			tc = colorbar;
			logscale_colorbar(tc);
			title(tc,'Median PSD');
				
		elseif f_count ==2
			h2 = pcolor(xb,yb,extras);
			shading interp;%flat; 
			hold on;
			contour(extras,'kx');
			tc2 = colorbar;
			%logscale_colorbar(tc2);
			title(tc2,'speed');
		elseif f_count == 3
			h3 = pcolor(xb,yb,tot);
			shading flat;
			tc3 = colorbar;
			title(tc3,'count in bin');
			
		end
	
	
		xlabel(sprintf('%s',par2));
		ylabel('Freq, mHz');
		
		
		% change x- and y-ticks to include value of that qunatile. Remember x,y switched from 1,2!
		if use_quantile_ticks
			xticks = get(gca,'XTickLabel');
			new_ticks = {};
			for t_count = 1:length(xticks)
				q_val = str2num(cell2mat(xticks(t_count))); % quantile 
				if q_val > numq2;
					xquant = max(cell2mat({data.(par2)}));
				else 
					xquant = quants2(q_val);
				end
				new_ticks(t_count) = {strcat(num2str(q_val),' / ',num2str(xquant,'%1.2e'))};
			end
			set(gca,'XTickLabel',new_ticks);
			set(gca,'XTickLabelRotation',-60);
		end
		
		% do you want to plot the quantile number or the value of that quantile?
		
		
		if f_count == 1
			title('PSD change across quantiles');
		elseif f_count ==2
			title(sprintf('corresponding speed median of %s',par2));
		end
		
		% figdirdate = '16-09-29';
		% if isempty(extra)
			% figtitle = sprintf('plots/%s_freq_par_plots/%s_%d',figdirdate,par2,f_count);
		% else
			% figtitle = strcat(sprintf('plots/%s_freq_par_plots/%s_%s_%d',figdirdate,par1,par2,f_count),extra);
		% end
		
		% savefig(figtitle);
	end
		
	
end
	
	
		
		