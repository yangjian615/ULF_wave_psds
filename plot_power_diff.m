% Intensity map of the power difference between time and energy domains
% Recall this is comparing with the mean subtracted

function []  = plot_power_diff( data, t_res )
	
	do_rescaled = true;%false;
	coord = 'x';
	
	ptag = get_ptag();
	
	all_x = cell2mat({data.(coord)});
	mean_x = mean(all_x,1);
	
	N = size(all_x,1); 
	time_axis = [1:N]*t_res;
	T = t_res*N; % total time
	
	all_mm_x = all_x;
	for c_count = 1:length(data)
		all_mm_x(:,c_count) = all_mm_x(:,c_count) - mean_x(c_count);
	end
	time_power_mm = trapz(time_axis,all_mm_x.^2)/T; % average power per unit time
	
	% spectral domain: get area under curve
	all_xps = cell2mat({data.(sprintf('%sps',coord))});
	spectral_power = trapz(data(1).freqs,all_xps);

	
	% check size
	if size(time_power_mm,1) ~= 1 | size(time_power_mm,2) ~= length(data)
		error('plot_power_diff:BadSize',' youve made an dimesnioal mistake someweher in time domain');
	elseif size(spectral_power,1) ~= 1 | size(spectral_power,2) ~= length(data)
		error('plot_power_diff:BadSize',' youve made an dimesnioal mistake someweher in freq domain');
	end
	
	
	% Plot intensity map of the energy in each domain
	xedges = logspace(-1,6,200);
	yedges = xedges;
	
	n = bin_2d_data([time_power_mm' spectral_power'],xedges, yedges);
	n(end+1,:) = 0; n(:,end+1) = 0;
	
	[xb,yb] = meshgrid(xedges,yedges);
	
	h = pcolor(xb,yb, n');
	cmap = colormap;
	cmap(1,:) = [1 1 1];
	colormap(cmap);
	shading flat;
	
	tc = colorbar;
	title(tc,'counts in bin');
	
	set(gca,'yscale','log');
	set(gca,'xscale','log');
	
	xlabel('Energy in time domain');
	ylabel('Energy in spectral domain');
	
	hold on;
	plot(xedges,yedges,'r');
	legend('y=x');
	title('Power in time and spectral domains');
	
	
	
	% Plot histogram of the differences scaled by the mean of the two values
	
	figure(2);
	both_mean = mean([time_power_mm',spectral_power'],2);
	diff = abs( time_power_mm - spectral_power );
	
	histogram( diff./both_mean' );
	ylabel('Count');
	xlabel('Difference between the values, scaled by mean value');
	
	title('Differences in energy in time/freq domains');
	
	
	% And a scatter plot of them too so we can see anomlaies
	figure(3);
	scatter(time_power_mm,spectral_power,'.');
	
	
	set(gca,'yscale','log');
	set(gca,'xscale','log');
	
	xlabel('Energy in time domain');
	ylabel('Energy in spectral domain');
	
	
	hold on;
	plot(xedges,yedges,'r');
	title('Scatter of power in time and spectral domains');
	
	% do rescaled here: check power is same when changing units (it really should be!)
	if do_rescaled
		% mHz for freq and (nT)^2 / mHz for PSD
		
		
		% use fn to do it
		scaled_data = rescale_power(data);
		
		% get area under curve
		scaled_spectral_power = trapz(scaled_data(1).freqs,cell2mat({scaled_data.(sprintf('%sps',coord))}));
		
		xedges = logspace(-1,6,200);
		yedges = xedges;
		
		figure(4);
		n = bin_2d_data([time_power_mm' scaled_spectral_power'],xedges, yedges);
		n(end+1,:) = 0; n(:,end+1) = 0;
		
		[xb,yb] = meshgrid(xedges,yedges);
		
		h = pcolor(xb,yb, n');
		cmap = colormap;
		cmap(1,:) = [1 1 1];
		colormap(cmap);
		shading flat;
		
		tc = colorbar;
		title(tc,'counts in bin');
		
		set(gca,'yscale','log');
		set(gca,'xscale','log');
		
		xlabel('Energy in time domain');
		ylabel('Energy in spectral domain');
		
		hold on;
		plot(xedges,yedges,'r');
		legend('y=x');
		title('Power in time and spectral domains using different units');
	end
end	