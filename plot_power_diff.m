% Intensity map of the power difference between time and energy domains
% Recall this is comparing with the mean subtracted

function []  = plot_power_diff( data, t_res )
	
	coord = 'x';
	
	ptag = get_ptag();
	
	all_x = cell2mat({data.(coord)});
	mean_x = mean(all_x,1);
	
	all_mm_x = all_x;
	for c_count = 1:length(data)
		all_mm_x(:,c_count) = all_mm_x(:,c_count) - mean_x(c_count);
	end
	time_power_mm = sum( (all_mm_x).^2 )*t_res;
	% try trapz version of this?
	
	% Because of Matlab's funny  scaling we just add and dont multiply by f_res
	all_xps = cell2mat({data.(sprintf('%sps',coord))});
	spectral_power = sum( all_xps );
	
	% check size
	if size(time_power_mm,1) ~= 1 | size(time_power_mm,2) ~= length(data)
		error('plot_power_diff:BadSize',' youve made an dimesnioal mistake someweher in time domain');
	elseif size(spectral_power,1) ~= 1 | size(spectral_power,2) ~= length(data)
		error('plot_power_diff:BadSize',' youve made an dimesnioal mistake someweher in freq domain');
	end
	
	
	% Plot intensity map of the energy in each domain
	xedges = logspace(2,10,200);
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
	
end	