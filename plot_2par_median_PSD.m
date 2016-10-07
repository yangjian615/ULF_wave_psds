% Takes 2 parameters, takes as many quantiles of each and plots the median PSD at the given frequency
% par1,2 should be string s of field, numq1,2, integers adn whichfreq in mHz
% num_conts is optional argument, just an integer please
% par_opts also optional, you can specify lin or log for different sorting inside sort_by_speed_sectors, expect a cell of two strings

function [res,min_in_med] = plot_2par_median_PSD( data, par1, par2, nbins, whichfreq, num_conts, par_opts )

	coord = 'x'; % youll want to feed this in a t some point
	use_quantile_ticks = false;
	
	ptag = get_ptag();
	do_print(ptag,2,'plot_2par_median_PSD:entering fn \n');

	do_print(ptag,3,sprintf('plot_2par_median_PSD:plotting at freq %d \n',whichfreq));
	
	% Sort out inputs
	numq1 = nbins(1);
	numq2 = nbins(2);
	use_par_opts = false;
	switch nargin
		case 5
			num_conts = [];
		case 7 % have par_opts, check them
			use_par_opts = true;
			if ~iscell(par_opts)
				error('plot_2par_median_PSD:BadInput',' non-cell input given for par_otps');
			elseif length(par_opts) ~= 2
				error('plot_2par_median_PSD:BadInput',' need 2 inputs in par_otps cell');
			elseif ~isstr(par_opts{1}) | ~isstr(par_opts{2})
				error('plot_2par_median_PSD:BadInput',' non-string inside par_otps cell');
			end
	end
			
			
	
	
	% first get the frequency
	freqs = data(1).freqs;
	
	if isempty(whichfreq)
		error('plot_2par_median_PSD:NoInput','need a frequency to plot at');
	end
	
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
	tot = nan(numq1+1,numq2+1); % so we know amount used
	extras = nan(numq1+1,numq2+1); % if you want to display mdeina speed etc
	bin_centres1 = nan(1,length(numq1+1));
	bin_centres2 = nan(1,length(numq2+1));
	
	% remove data wtith unphyscial PSD values, same as whebn using wrapper fns. Use default values, don't bother to hand in.
	temp_gopts =make_basic_struct('gen_opts');
	power = cell2mat({data.(sprintf('%sps',coord))});
	power = power(which_col,:);
	ok_vals = (power >= temp_gopts.pop_lim(1)) & (power < temp_gopts.pop_lim(2));
	data = data(ok_vals);
	
	% get lists of which  quantile data lies in for each par
	if use_par_opts
		[quants1,which_q1] = sort_by_speed_sectors(cell2mat({data.(par1)}),numq1,par_opts{1});
		[quants2,which_q2] = sort_by_speed_sectors(cell2mat({data.(par2)}),numq2,par_opts{2});
	else
		[quants1,which_q1] = sort_by_speed_sectors(cell2mat({data.(par1)}),numq1);
		[quants2,which_q2] = sort_by_speed_sectors(cell2mat({data.(par2)}),numq2);
	end
	
	% check you have good quantiles
	if length(unique(quants1)) ~= length(quants1) | length(unique(quants2)) ~= length(quants2) 
		error('plot_2par_median_PSD:BadQuantilesFound',' non-unique quantiles, may be due to structure of data, esp if OMNI');
	end
	
	
	% keep track of minimum used to calculate median [q1,q2,num_in_med]
	min_in_med = [1,1,length(data)];
	
	for q1 = 1:numq1+1
		
		%data_selection(1).which_quants = q1;
		% get the bin centres
		bin_centres1(q1) = median( cell2mat({data( which_q1 == q1 ).(par1)}) );
		
		if isnan(bin_centres1(q1))
			bin_centres1(q1) = quants1(q1);
		end
		
	
		for q2 = 1:numq2+1
			
			% get the bin centres
			if q1 == 1
				bin_centres2(q2) = median( cell2mat({data( which_q2 == q2 ).(par2)}) );
				
				
			if isnan(bin_centres2(q2))
				bin_centres2(q2) = quants2(q2);
			end
				
			end
			
			
			
			in_both = which_q1 == q1 & which_q2==q2;
			
			
			if sum(in_both) > 0
				selected_data = data( in_both );
				all_pow = cell2mat({selected_data.(sprintf('%sps',coord))});
				all_pow = all_pow(which_col,:);
				
				extra_info = cell2mat({selected_data.speed});
				extra_info = extra_info;
				
				if length(size(all_pow)) > 2 | (size(all_pow,1) > 1 & size(all_pow,2) >1)
					error('plot_2par_median_PSD:BadVarSize',' median wont be scalar');
				end
				do_print(ptag,3,sprintf('plot_2par_median_PSD: for qs %d,%d : %d used for median \n',q1,q2,length(all_pow)));
				
				if length(selected_data) < min_in_med(3)
					min_in_med = [q1,q2,length(selected_data)];
				end
				
				
				res(q1,q2) = median(all_pow);
				tot(q1,q2) = length(all_pow);%/res(q1,q2);
				extras(q1,q2) = median(extra_info);
				
			else 
				do_print(ptag,2,sprintf('plot_2par_median_PSD: No data for case of quantiles %d, %d \n',q1,q2'));
				res(q1,q2) = 0;
				tot(q1,q2) = 0;
				extras(q1,q2) = 0;
			end
			
			
		end
		do_print(ptag,3,sprintf('plot_2par_median_PSD:done first par iteration %d \n',q1));
	end

	
	% check output
	if sum(sum(sum(isnan(res)))) > 0 
		error('plot_2par_median_PSD:BadResult','got nans still, in res'); 
	elseif sum(isnan(bin_centres1)) > 0
		error('plot_2par_median_PSD:BadResult','got nans still, in bincentres 1');
	elseif sum(isnan(bin_centres2)) > 0 
		error('plot_2par_median_PSD:BadResult','got nans still, in bincentres 2');
	end
	
	
	if use_quantile_ticks
		x_axis = 1:numq2+1; y_axis = 1:numq1+1; % by quantile number
	else
		x_axis = bin_centres2; y_axis = bin_centres1; % by value at centre of quantile
	end
	%
	
	%plot it. Use log to mess with colorbar
	[xb,yb] = meshgrid(x_axis,y_axis); 
	
	% deal with zeroes in res for log
	log_res = res;
	log_res( res ~= 0 ) = log(res( res~= 0 ));
	
	
	% two loops one for pcolor and conotour, one for whatever you want?
	for f_count = 1:3
		figure(f_count);
		if f_count ==1 
			h = pcolor(xb,yb,log_res);
			shading flat
			%shading interp;% grid on;
			hold on;
			%grid on; set(gca,'layer','top');
			if isempty(num_conts)
				contour(x_axis,y_axis,log_res,'k');	
			else
				contour(x_axis,y_axis,log_res,num_conts,'k');
			end
			
			make_cmap_lowest_white();
			tc = colorbar;
			logscale_colorbar(tc);
			title(tc,'Median PSD');
			
			% overlay speed contours.
			%caxis([min(min(log(res))),max(max(log(res)))]);
			%contour(x_axis,y_axis,extras,'k-.');
				
		elseif f_count ==2
			h2 = pcolor(xb,yb,extras);
			shading interp;%flat; 
			hold on;
			contour(x_axis,y_axis,extras,'k');

			make_cmap_lowest_white();
			tc2 = colorbar;
			%logscale_colorbar(tc2);
			title(tc2,'speed');
		elseif f_count == 3
			h3 = pcolor(xb,yb,tot);
			%shading flat;
			
			make_cmap_lowest_white();
			tc3 = colorbar;
			title(tc3,'count in bin');
			
		end
		
		%set(gca,'xscale','log');
		%set(gca,'yscale','log');
		ylabel(sprintf('%s',par1));
		xlabel(sprintf('%s',par2));
		
		
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
			yticks = get(gca,'YTickLabel');
			new_ticks = {};
			for t_count = 1:length(yticks)
				q_val = str2num(cell2mat(yticks(t_count))); % quantile 
				if q_val > numq1
					yquant = max(cell2mat({data.(par1)}));
				else 
					yquant = quants1(q_val);
				end
				new_ticks(t_count) = {strcat(num2str(q_val),' / ',num2str(yquant))};
			end
			set(gca,'YTickLabel',new_ticks);
		end
		
		
		if f_count == 1
			title(sprintf('PSD change across quantiles, %1.2f mHz',whichfreq));
		elseif f_count ==2
			title(sprintf('corresponding speed median of %s,%s',par1,par2));
		end
		
		figdirdate = '16-10-03';
		figtitle = sprintf('plots/%s_2par_plots/%s_%s_%d',figdirdate,par1,par2,f_count);
		
		saveas(gcf,strcat(figtitle,'.jpg'));
	end
		
	
end
	
	
		
		