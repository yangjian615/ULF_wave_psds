% Takes in a datenum, shows this viusllay. Years, months on x axis, days on y axis, colour corresponds to 
% percentage of time covered there. 

% Could do: Y-axis converted to "ratio of seconds throughh month" so all the same size
function [n] = plot_time_coverage( d_times, win_mins )
	
	ptag = get_ptag();
	
	dates_mat = datevec( d_times );
	
	d_months = dates_mat;
	d_months(:,3:6) = 0;
	d_months = datenum(d_months);
	
	d_month_end = datevec(d_months(end,:)); d_month_end(2) = d_month_end(2)+1; d_month_end = datenum(d_month_end);
	month_bin_edges = vertcat(unique(d_months),d_month_end);
	
	%TIDY THIS  AND TESTING.
	
	m_bins = length(unique(d_months));

	
	d_day = dates_mat(:,3);
	d_bins =length(unique(d_day));
	
	day_bin_edges = [-0.5:1:31.5]; %these are OK as we only have integers
	
	do_print(ptag,2,sprintf('plot_time_coverage: using %d bins each month, %d bins for years and months\n',d_bins,m_bins));
	
	%[n,xedges,yedges] = linlinhist3( d_months, d_day, [m_bins,d_bins]);
	n = bin_2d_data([d_months,d_day],month_bin_edges,day_bin_edges);
	xedges = month_bin_edges;
	yedges = day_bin_edges;
	
	% Note that I am really not convinced by the exact edges etc you have here, there's some weird fiddling going on in all your plotting funcitons
	
	
	
	% Each bin should be a day. So how much of that day is represented?
	%ASSUMES WINDOW LENGTH SMALLER THAN ONE DAY.
	% A percentage	
	n = (n*win_mins /(24*60))*100;
	
	ycentres = lin_edges_to_mids(yedges);
	xcentres = lin_edges_to_mids(xedges);
	
	[xb,yb] = meshgrid(xcentres,ycentres);
	
	
	h = pcolor(xb,yb,n');
	h.ZData = ones(size(n')) * -max(max(n));
	
	%colormap(copper);
	%cmap = colormap;
	%cmap(1,:) = [1 1 1];
	cmap = ccmap(rgb('darkred'));
	cmap = flipud(cmap);
	cmap(1,:) = [1 1 1];
	colormap(cmap);
	
	shading flat;%interp;
	datetick('x',22);
	
	colorbar('eastoutside');
	title('Percentage of data in each day');
	ylabel('Day of month');
end


	
	