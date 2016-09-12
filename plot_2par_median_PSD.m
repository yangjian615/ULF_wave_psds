% Takes 2 parameters, takes as many quantiles of each and plots the median PSD at the given frequency
% par1,2 should be string s of field, numq1,2, integers adn whichfreq in mHz

function [res,min_in_med] = plot_2par_median_PSD( data, par1, par2, numq1,numq2, whichfreq, extra )

	coord = 'x'; % youll want to feed this in a t some point

	ptag = get_ptag();
	do_print(ptag,2,'plot_2par_median_PSD:entering fn \n');

	% first get the frequency
	freqs = data(1).freqs*1e3;
	
	
	f_tol = 0.0001; % frequency tolerance
	do_print(ptag,2,sprintf('plot_2par_median_PSD: freq tol is %d \n',f_tol));
	
	which_col = abs(whichfreq - freqs) < f_tol;
	% would be quicker to use this to eliminate data first but too complciated

	% make selection strcut 
	data_selection = [];
	data_selection(1).o_f = par1;
	data_selection(2).o_f = par2;
	data_selection(1).num_quants = numq1; 
	data_selection(2).num_quants = numq2;
	
	% initialise results matrix
	res  = nan(numq1+1,numq2+1);
	
	% remove data wtith unphyscial PSD values, same as whebn using wrapper fns. Use default values, don't bother to hand in.
	temp_gopts =make_basic_struct('gen_opts');
	power = cell2mat({data.(sprintf('%sps',coord))});
	power = power(which_col,:);
	ok_vals = (power >= temp_gopts.pop_lim(1)) & (power < temp_gopts.pop_lim(2));
	data = data(ok_vals);
	
	% get lists of which  quantile data lies in for each par
	[quants1,which_q1] = sort_by_speed_sectors(cell2mat({data.(par1)}),numq1);
	[quants2,which_q2] = sort_by_speed_sectors(cell2mat({data.(par2)}),numq2);
	
	% keep track of minimum used to calculate median [q1,q2,num_in_med]
	min_in_med = [1,1,length(data)];
	
	for q1 = 1:numq1+1
		
		%data_selection(1).which_quants = q1;
	
		for q2 = 1:numq2+1
			
			%data_selection(2).which_quants = q2;
			
			%get data selected
			% you may need to speed this up by getting indices instead of passing out stuff
			% this is so slow as it recalculates EVERY time. Surely you only need to do once? Different function?
			%selected_data = select_quantiles(data,data_selection);
			
			in_both = which_q1 == q1 & which_q2==q2;
			
			if sum(in_both) > 0
				selected_data = data( in_both );
				all_pow = cell2mat({selected_data.(sprintf('%sps',coord))});
				all_pow = all_pow(which_col,:);
				
				if length(size(all_pow)) > 2 | (size(all_pow,1) > 1 & size(all_pow,2) >1)
					error('plot_2par_median_PSD:BadVarSize',' median wont be scalar');
				end
				do_print(ptag,2,sprintf('plot_2par_median_PSD: for qs %d,%d : %d used for median \n',q1,q2,length(all_pow)));
				
				if length(selected_data) < min_in_med(3)
					min_in_med = [q1,q2,length(selected_data)];
				end
				
				
				res(q1,q2) = median(all_pow);
			else 
				do_print(2,ptag,sprintf('plot_2par_median_PSD: No data for case of quantiles %d, %d \n',q1,q2'));
				res(q1,q2) = 0;
			end
			
			
		end
		do_print(ptag,3,sprintf('plot_2par_median_PSD:done first par iteration %d \n',q1));
	end
	
	% check output
	if sum(sum(isnan(res))) > 0 
		error('plot_2par_median_PSD:BadResult','got nans still1');
	end
	
	
	% get blank space for zero values
	cmap = colormap;
	cmap(1,:) = [1 1 1];
	colormap(cmap);	% how much are we cutting out??
	
	%plot it. Use log to mess with colorbar
	[xb,yb] = meshgrid(1:numq2+1,1:numq1+1);
	warning('plot_2par_median_PSD:meshgrid seems to be abakwards but you should really check this');
	
	% two loops one for conotour and one for pcolor
	for f_count = 1:2
		figure(f_count);
		if f_count ==1 
			h = pcolor(xb,yb,log(res));
			shading flat;
		else	
			contour(log(res));
		end
	
		ylabel(sprintf('%s',par1));
		xlabel(sprintf('%s',par2));
		
		% do you want to plot the quantile number or the value of that quantile?
		
		tc = colorbar;
		logscale_colorbar(tc);
	
		figdirdate = '16-09-09';
		if isempty(extra)
			figtitle = sprintf('plots/%s_2par_plots/%s_%s_%d',figdirdate,par1,par2,f_count);
		else
			figtitle = strcat(sprintf('plots/%s_2par_plots/%s_%s_%d',figdirdate,par1,par2,f_count),extra);
		end
		
		savefig(figtitle);
	end
		
	
end
	
	
		
		