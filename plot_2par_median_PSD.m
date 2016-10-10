% Takes 2 parameters, takes as many quantiles of each and plots the median PSD at the given frequency
% par1,2 should be string s of field, numq1,2, integers adn whichfreq in mHz
% num_conts: is optional argument, just an integer please
% par_opts: also optional, you can specify lin or log for different sorting inside sort_by_speed_sectors, expect a cell of two strings
% par_lims: you can apply limits to your parameters by supply a 4-vec in par_lims, [lowllim1,hilim1,lolim2,hilim2];
%  	this is last as it's only really useful when specifyinglin/log vluueas

function [res,min_in_med] = plot_2par_median_PSD( data, par1, par2, nbins, whichfreq, num_conts, par_opts, par_lims )

	coord = 'x'; % youll want to feed this in a t some point
	use_quantile_ticks = false;
	
	ptag = get_ptag();
	do_print(ptag,2,'plot_2par_median_PSD:entering fn \n');

	do_print(ptag,3,sprintf('plot_2par_median_PSD:plotting at freq %d \n',whichfreq));
	
	% Sort out inputs
	numq1 = nbins(1);
	numq2 = nbins(2);
	use_par_opts = false;
	if nargin == 5
		num_conts = [];
	end
	% check par_opts if given
	if nargin > 6 & ~isempty(par_opts)
		use_par_opts = true;
		if ~iscell(par_opts)
			error('plot_2par_median_PSD:BadInput',' non-cell input given for par_otps');
		elseif length(par_opts) ~= 2
			error('plot_2par_median_PSD:BadInput',' need 2 inputs in par_otps cell');
		elseif ~isstr(par_opts{1}) | ~isstr(par_opts{2})
			error('plot_2par_median_PSD:BadInput',' non-string inside par_otps cell');
		end
	end
	% apply par_lims if given
	if nargin > 7 & ~isempty(par_lims)
	%This shouldnt really be here as you are doing processing rather than settin gup, but oh well.
		do_print(ptag,2,'plot_2par_median_PSD: removing data outside requested limits \n');
		par1s = cell2mat({data.(par1)});
		ok1 = par1s >= par_lims(1) & par1s <= par_lims(2);
		
		par2s = cell2mat({data.(par2)});
		ok2 = par2s >= par_lims(3) & par2s <= par_lims(4);
		
		data = data(ok1&ok2);
	end
			
			
			
	% also get rid of any nans if they exist
	par1s = cell2mat({data.(par1)});
	ok1 = ~isnan(par1s);
		
	par2s = cell2mat({data.(par2)});
	ok2 = ~isnan(par2s);
	
	if sum(isnan(par1s)) > 0 
		do_print(ptag,2,'plot_2par_median_PSD: removing par1 data that are nans \n');
	end
	if sum(isnan(par2s)) > 0 
		do_print(ptag,2,'plot_2par_median_PSD: removing par2 data that are nans \n');
	end
	data = data(ok1&ok2);
	

	
	% first get the frequency
	freqs = data(1).freqs;
	
	if isempty(whichfreq)
		error('plot_2par_median_PSD:NoInput','need a frequency to plot at');
	end
	
	f_tol = 0.0001; % frequency tolerance
	do_print(ptag,2,sprintf('plot_2par_median_PSD: freq tol is %d \n',f_tol));
	
	which_col = abs(whichfreq - freqs) < f_tol;
	% would be quicker to use this to eliminate data first but too complciated

	
	% initialise results matrix
	res  = nan(numq1,numq2);
	tot = nan(numq1,numq2); % so we know amount used
	extras = nan(numq1,numq2); % if you want to display mdeina speed etc
	bin_centres1 = nan(1,length(numq1));
	bin_centres2 = nan(1,length(numq2));
	
	% remove data wtith unphyscial PSD values, same as whebn using wrapper fns. Use default values, don't bother to hand in.
	temp_gopts =make_basic_struct('gen_opts');
	power = cell2mat({data.(sprintf('%sps',coord))});
	power = power(which_col,:);
	ok_vals = (power >= temp_gopts.pop_lim(1)) & (power < temp_gopts.pop_lim(2));
	data = data(ok_vals);
	
	% get lists of which  quantile data lies in for each part
	% these must match, therefore they need min and max values too.
	if use_par_opts
		[quants1,which_q1] = sort_by_speed_sectors(cell2mat({data.(par1)}),numq1+2,par_opts{1});
		[quants2,which_q2] = sort_by_speed_sectors(cell2mat({data.(par2)}),numq2+2,par_opts{2});
	else
		par1s = cell2mat({data.(par1)});
		par2s = cell2mat({data.(par2)});
		[quants1,which_q1] = sort_by_speed_sectors(par1s,numq1);
		[quants2,which_q2] = sort_by_speed_sectors(par2s,numq2);
		
		quants1 = cat(2,min(par1s),quants1,max(par1s));
		quants2 = cat(2,min(par2s),quants2,max(par2s));
	end
	
	% check you have good quantiles
	if length(unique(quants1)) ~= length(quants1) | length(unique(quants2)) ~= length(quants2) 
		error('plot_2par_median_PSD:BadQuantilesFound',' non-unique quantiles, may be due to structure of data, esp if OMNI');
	end
	

	% keep track of minimum used to calculate median [q1,q2,num_in_med]
	min_in_med = [1,1,length(data)];
	
	for q1 = 1:numq1
		
		%data_selection(1).which_quants = q1;
		% get the bin centres
		bin_centres1(q1) = median( cell2mat({data( which_q1 == q1 ).(par1)}) );
		
		if isnan(bin_centres1(q1))
			bin_centres1(q1) = mean( [quants1(q1),quants1(q1+1)] );
		end
		% you need to make them take mean instead i think.
	
		for q2 = 1:numq2
			% get the bin centres
			if q1 == 1
				bin_centres2(q2) = median( cell2mat({data( which_q2 == q2 ).(par2)}) );
				
				
			if isnan(bin_centres2(q2))
				disp(q2);
				bin_centres2(q2) = mean( [quants2(q2),quants2(q2+1)] );
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
				do_print(ptag,3,sprintf('plot_2par_median_PSD: No data for case of quantiles %d, %d \n',q1,q2'));
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
	
	% check your axes are increasing
	if sum( (x_axis(2:end) - x_axis(1:end-1)) <= 0 ) > 0
		disp(x_axis);
		error('plot_2par_median_PSD: not monotonically increasing x axis wont work');
	end
	if sum( (y_axis(2:end) - y_axis(1:end-1)) <= 0 ) > 0
		disp(y_axis);
		error('plot_2par_median_PSD: not monotonically increasing y axis wont work');
	end


	
	% two loops one for pcolor and conotour, one for whatever you want?
	for f_count = 1:3
		figure(f_count);
		if f_count ==1 
			h = pcolor(xb,yb,log_res);
			shading flat
			
			% you can use nicer shadin with consistent bin sizes
			if use_par_opts & ~strcmp(par_opts{1},'quantile') & ~strcmp(par_opts{2},'quantile')
				shading interp;% grid on;
			end
			
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
		
		%saveas(gcf,strcat(figtitle,'.jpg'));
	end
		
	
end
	
	
		
		