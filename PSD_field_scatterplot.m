% Input:
% data_dir
% station
% years
% months
% field - string corresponding to field of omni data, eg 'speed'
% coord - character, 'x', 'y' or 'z'
% sample_freq - required freq in milli Hz

% We can do the scatterplots for a single frequency or at every frequency between 0.001 and 15. We can also plot the means and 
% medians on top of this.

% We can plot all these on a 3d scatter plot and triangulate a 3d shape around them but this isn't very helpful as rendering is so poor.

% We can work out the histogram and plot an intensity map of the scatter plot to increase information. We can also 
% plot the filled in contours for each of this (contours chosen by MATLAB) or plot the contour lines on top of the scatterplot.
% These contours are chosen logarithmically and are all plotted in a single colour because the colormap only makes sense linearly and I don't see the point in fiddling too much.

function [] = PSD_field_scatterplot( data_dir, station, years, months, sample_freq, all_data,data_bins )
	
	
	warning('This is bad code, it grew too big. Write new stuff if possible');
	
	coord = 'x';
	o_field = 'speed';
	ps_or_psd = 'ps';
	
	plot_mlines = true;
	do_all = false;
	plot_3dscatter = false;
	plot_3dtriang = false;
	plot_scatter = true; add_scatter_contour = true;
	plot_hist = true;
	keep_outliers = false;
	plot_contours = false;
	middle_bins_only = false; % only really for Np as weird differences!
	n_conts = 6;
	plot_top_straight_line = true;
	plot_separate_MLT = true; %will only do for a single freq atm
	
	if do_all 
		plot_separate_MLT = false;
	end
	
	
	mlts = 1;
	if plot_separate_MLT
		mlts = [1:4];
	end
	
	disp(sprintf('Scatter plot for data at freq %f mHz',sample_freq));
	%h1 = figure();
	%h2 = figure();
	
	% load in required data
	if isempty(all_data)
		[all_data,data_bins] = get_all_psd_data(data_dir,station,years,months);
	end
	

	freqs = calcfreqs(cell2mat({all_data(1).x}),all_data(1).times,[] );
	
	% set up axes
	axis_lim = [];
	if strcmp(ps_or_psd,'psds')
		of_range = max(cell2mat({all_data.(o_field)}))- min(cell2mat({all_data.(o_field)}));
		axis_lim = [min(cell2mat({all_data.(o_field)}))-0.1*of_range,max(cell2mat({all_data.(o_field)}))+0.1*of_range, 0.1e0,9e10];
	elseif strcmp(ps_or_psd,'ps')
		of_range = max(cell2mat({all_data.(o_field)}))- min(cell2mat({all_data.(o_field)}));
		axis_lim = [min(cell2mat({all_data.(o_field)}))-0.1*of_range,max(cell2mat({all_data.(o_field)}))+0.1*of_range, 0.1e-4,9e7];
		if strcmp(o_field,'Np')
			disp('Careful: two very different plots for density depending on limits!');
			axis_lim = [1,inf, 0.1e-4,9e7];
			if middle_bins_only
				axis_lim = [2,9,0.1e-4,9e7];
			end
		end
	else
		error('>>> PS or PSD??? <<<');
	end
	axis(axis_lim);
	
	
	if sum( freqs == sample_freq ) ~= 1
		error('>>> No frequency match!!! <<<');
	end
	
	if plot_3dtriang  % set up mahusive P
		P = ones(length(years)*length(months)*31*24,3);
		p_count = 1;
	end
	
	the_inds = 1;
	if do_all
		the_inds = [2:55];
	end
	
	for sf_ind = the_inds
		for m_count = mlts
			if do_all
				sample_freq = freqs(sf_ind);
			end
			vals = cell2mat({all_data.(sprintf('%s%s',coord,ps_or_psd))});
			vals = vals(freqs == sample_freq, :);
			
			power_lims = [1e-5,1e11];%[0.7,1.5e5]; %ONLY SET FOR PSDs, NOT THE POWER SPECTRA
			ok_vals = (vals >= power_lims(1)) & (vals < power_lims(2));
			
			badvalinds = find(~ok_vals);
			if sum(~ok_vals) > 0
				for k = [1:sum(~ok_vals)]
					disp(sprintf('Outlier at %s',char(datetime(datevec(cell2mat({all_data(badvalinds(k)).dates}))))'));
				end
				if ~keep_outliers
					ok_vals = true(size(ok_vals));
				end
			end
			
			vals = vals(ok_vals);
			all_data = all_data(ok_vals);
			
			if strcmp(o_field,'Np') & middle_bins_only
				disp('Only keeping the middle bit!!!');
				ok_vals = cell2mat({all_data.Np}) >= 2 & cell2mat({all_data.Np}) <= 9;
				vals = vals(ok_vals);
				all_data = all_data(ok_vals);
			end
			
			% get x and y vals I will use
			this_mlt = cell2mat({all_data.MLT}) == m_count;
			if ~plot_separate_MLT
				this_mlt = true(size(this_mlt));
			end
			
			xs = cell2mat({all_data(this_mlt).(o_field)});
			ys = vals(this_mlt);
			this_all_data = all_data(this_mlt);
			
			
			if plot_scatter
				figure(1);
				if do_all
					subplot(6,9,sf_ind-1);
				elseif plot_separate_MLT
					subplot(2,2,m_count);
				end
				sc_col = [7 144 203] ./ 255;
				%annotation('textbox',[0.05 0.7 0.2 0.2],'String',sprintf('freq %.3f mHz',sample_freq),'FitBoxToText','on','EdgeColor','none','FaceAlpha',0);
				
				
				scatter(xs,ys,7,sc_col,'.'); hold on;
				% if strcmp(o_field,'Np')
					% set(gca,'xscale','log');
				% end
				set(gca,'yscale','log');
				axis(axis_lim);
				%xlabel(sprintf('%s',o_field));
				%xlabel(sprintf('Solar wind %s, km s^{-1}',o_field));
				ax.XTickLabelRotation=45;
				title(sprintf('freq %.4f mHz',sample_freq),'FontSize',8);
				
				if plot_separate_MLT
					text(0.9*max(xs),0.9*max(ys),sprintf('MLT bin %d',m_count));
				end
				
				ratio = 0.98;
				[par] = top_straight_line(xs,log(ys),ratio);
				plot(xs,exp(par)*ones(1,length(ys)),'r');
				text(max(xs),exp(par)*1,sprintf('%.2f of data below %.2e',ratio,exp(par)));
				
			end
			if plot_hist | add_scatter_contour
				figure(2);
				if do_all
					subplot(6,9,sf_ind-1);
				elseif plot_separate_MLT
					subplot(2,2,m_count);
				end
				%lvals = log10(vals);
				nbins = 50;
				%xedges = linspace(min(cell2mat({all_data.(o_field)}))-1,max(cell2mat({all_data.(o_field)}))+1,nbins);
				%yedges = logspace(-5,10,nbins);
				
				
				[n,xbb,ybb,n1,xb,yb,n_flat] = linloghist3(xs,ys,[nbins,nbins]);
				
				
				if plot_hist
					h = pcolor(xb,yb,n1);
					h.ZData = ones(size(n1)) * -max(max(n));
					colormap(parula);
					cmap = colormap;
					cmap = rescale_colormap(cmap,n_flat(n_flat~=0));
					%warning('>>>rescaling of colormap turned off, no toolbox<<<');
					cmap(1,:) = [1 1 1];
					colormap(cmap);
					shading flat;
					axis(axis_lim);
					%grid on
					%xlabel('speed');
					%ylabel('Power');
					set(gca,'yscale','log');
					% if strcmp(o_field,'Np')
						% set(gca,'xscale','log');
					% end
					%view(3);
					view(0,90);
					if ~do_all | sf_ind==55
						colorbar('east');
					end
					
					if plot_separate_MLT
						text(900,1e-3,sprintf('MLT bin %d',m_count),'FontSize',8);
					end
				
					
					ax.XTickLabelRotation=45;
					title(sprintf('freq %.4f mHz',sample_freq),'FontSize',8);
				end
				
				if plot_contours
					figure(5);
					if do_all
						subplot(6,9,sf_ind-1);
					elseif plot_separate_MLT
						subplot(2,2,m_count);
					end
					%contour(C{2},C{1},n');
					%pick_levels = logspace(min(min(n1(n1 ~= 0))),max(max(n1)),n_conts);
					contourf(xb,yb,n1,n_conts);
					axis(axis_lim);
					ax.XTickLabelRotation=45;
					title(sprintf('freq %.4f mHz',sample_freq),'FontSize',8);
				
					set(gca,'yscale','log');
					if strcmp(o_field,'Np')
						set(gca,'xscale','log');
					end				
				end
				if add_scatter_contour
					figure(1);
					
					if do_all
						subplot(6,9,sf_ind-1);
					elseif plot_separate_MLT
						subplot(2,2,m_count);
					end
					pick_levels = quantile(n_flat(n_flat~=0),n_conts);%logspace(log10(min(min(n(n ~= 0)))),log10(max(max(n))),n_conts);
					ccol = [19 50 66] ./ 255;
					for clevel = [1:n_conts]
						contour(xb,yb,n1,[pick_levels(clevel),pick_levels(clevel)],'LineColor',ccol);
					end
				end
			end
			
			
			if plot_mlines
				[meds,means]=getstuffscatter(this_all_data,coord,ps_or_psd);
				meds = meds(freqs == sample_freq,:);
				means = means( freqs == sample_freq,:);
				
				col1 = [227 96 1] ./ 255;
				col2 = [169 52 137] ./ 255;%[155 95 176] ./ 255;;
				col3 = [136 165 242] ./ 255;
				
				lwidth = 0.5;
				% plot medians for bins
				h1 = plot([min(cell2mat({this_all_data.speed})) cell2mat(data_bins.speed(1))],[meds(1) meds(1)],'LineWidth', lwidth,'color',col1);
				plot([cell2mat(data_bins.speed(1)) cell2mat(data_bins.speed(2))],[meds(2) meds(2)],'LineWidth', lwidth,'color',col1);
				plot([cell2mat(data_bins.speed(2)) cell2mat(data_bins.speed(3))],[meds(3) meds(3)],'LineWidth', lwidth,'color',col1);
				plot([cell2mat(data_bins.speed(3)) cell2mat(data_bins.speed(4))],[meds(4) meds(4)],'LineWidth', lwidth,'color',col1);
				plot([cell2mat(data_bins.speed(4)) cell2mat(data_bins.speed(5))],[meds(5) meds(5)],'LineWidth', lwidth,'color',col1);
				plot([cell2mat(data_bins.speed(5)) max(cell2mat({all_data.speed}))],[meds(6) meds(6)],'LineWidth', lwidth,'color',col1);
				
				% join up the steps
				plot([cell2mat(data_bins.speed(1)) cell2mat(data_bins.speed(1))],[meds(1) meds(2)],'LineWidth', lwidth,'color',col1);
				plot([cell2mat(data_bins.speed(2)) cell2mat(data_bins.speed(2))],[meds(2) meds(3)],'LineWidth', lwidth,'color',col1);
				plot([cell2mat(data_bins.speed(3)) cell2mat(data_bins.speed(3))],[meds(3) meds(4)],'LineWidth', lwidth,'color',col1);
				plot([cell2mat(data_bins.speed(4)) cell2mat(data_bins.speed(4))],[meds(4) meds(5)],'LineWidth', lwidth,'color',col1);
				plot([cell2mat(data_bins.speed(5)) cell2mat(data_bins.speed(5))],[meds(5) meds(6)],'LineWidth', lwidth,'color',col1);
				
				
				%plot means for bins
				h2 = plot([min(cell2mat({this_all_data.speed})) cell2mat(data_bins.speed(1))],[means(1) means(1)],'LineWidth', lwidth,'color',col2);
				plot([cell2mat(data_bins.speed(1)) cell2mat(data_bins.speed(2))],[means(2) means(2)],'LineWidth', lwidth,'color',col2);
				plot([cell2mat(data_bins.speed(2)) cell2mat(data_bins.speed(3))],[means(3) means(3)],'LineWidth', lwidth,'color',col2);
				plot([cell2mat(data_bins.speed(3)) cell2mat(data_bins.speed(4))],[means(4) means(4)],'LineWidth', lwidth,'color',col2);
				plot([cell2mat(data_bins.speed(4)) cell2mat(data_bins.speed(5))],[means(5) means(5)],'LineWidth', lwidth,'color',col2);
				plot([cell2mat(data_bins.speed(5)) max(cell2mat({all_data.speed}))],[means(6) means(6)],'LineWidth', lwidth,'color',col2);
				
				% join up the steps
				plot([cell2mat(data_bins.speed(1)) cell2mat(data_bins.speed(1))],[means(1) means(2)],'LineWidth', lwidth,'color',col2);
				plot([cell2mat(data_bins.speed(2)) cell2mat(data_bins.speed(2))],[means(2) means(3)],'LineWidth', lwidth,'color',col2);
				plot([cell2mat(data_bins.speed(3)) cell2mat(data_bins.speed(3))],[means(3) means(4)],'LineWidth', lwidth,'color',col2);
				plot([cell2mat(data_bins.speed(4)) cell2mat(data_bins.speed(4))],[means(4) means(5)],'LineWidth', lwidth,'color',col2);
				plot([cell2mat(data_bins.speed(5)) cell2mat(data_bins.speed(5))],[means(5) means(6)],'LineWidth', lwidth,'color',col2);
			end
			%ft = 'a*((b+c*x^d)^e)';
			%plotfit = fit(cell2mat({all_data.(o_field)})',vals',ft,'StartPoint',[1 1 1 1 1]);
			%plot(plotfit);
			
			%disp(plotfit);
		
			
			%bdy = boundary(cell2mat({all_data.(o_field)})',vals',0.1);
			%plot(cell2mat({all_data(bdy).(o_field)}),vals(bdy),'color',col3);
			
			if plot_3dscatter
				figure(3);
				col_grading = (55-sf_ind)/60;
				scatter3(sample_freq*ones(size(ys)),xs,ys,7,sc_col*(col_grading),'.'); hold on;
				xlabel('freq');
				ylabel('Speed');
				zlabel('Power');
				set(gca,'zscale','log');
				
				if plot_3dtriang
					P(p_count:p_count+length(ys)-1,1) = xs;
					P(p_count:p_count+length(ys)-1,2) = ys;
					P(p_count:p_count+length(ys)-1,3) = sample_freq*ones(size(ys));
					p_count = p_count + length(ys);
				end
			end
		end
	end
	
	if plot_3dtriang
		P = P(1:p_count-1,:);
		P1 = P;
		P1(:,1) = P(:,3);
		P1(:,2) = P(:,1);
		P1(:,3) = P(:,2);
		P = P1;
		clear('P1');
		%legend([h1,h2],'medians','means','Location','southeast');
		disp('just finding boundary');
		bdy = boundary(P);
		disp('next is trisurf');
		figure(4);
		trisurf(bdy,P(:,1),P(:,2),P(:,3),'Facecolor','red','FaceAlpha',0.1);
		xlabel('freq');
		ylabel('Speed');
		zlabel('Power');
		set(gca,'zscale','log');
	end

end