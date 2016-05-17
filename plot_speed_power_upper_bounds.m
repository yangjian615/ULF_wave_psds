% uses function to fit a straight line to top of scatter data (ratio of data below can be specified)
% does for each freq at each station listed over all years
% plots it


function [] = plot_speed_power_upper_bounds(ddir, stations, ratio,plot_saved)

	% initialise stuff
	y = [1990:2004];
	m = [1:12];
	o_field = 'speed';
	pop = 'ps';
	f_lo = 0.9;
	f_hi = 15;
	coords = {'x','y','z'};
	if isempty(ratio) | abs(ratio -1) > 1
		ratio = 0.99;
	end
	if isempty(plot_saved)
		plot_saved = false;
	end
	f_name = strcat(ddir,'speed_power_upper_scatter_bounds');
	
	% fill in later
	freqs = []; in_window = []; use_freqs = []; tops =[];

	if ~plot_saved
		for st_count = [1:length(stations)]
			station = stations{st_count};
			[data,bins] = get_all_psd_data(ddir,station,y,m);
			
			if isempty(freqs)
				freqs = calcfreqs(cell2mat({data(1).x}),data(1).times,[] );
				in_window = freqs >= f_lo & freqs <= f_hi;
				use_freqs  = freqs(in_window);
				tops = nan(sum(in_window),length(coords),length(station));
			end
			
			for co_count = [1:length(coords)]
				coord = coords{co_count};
				disp(sprintf('Finding values for %s coord of %s',coord,station));
			
				% for each sample frequency
				for sf_count = [1:sum(in_window)]
					sf = use_freqs(sf_count);
				
					%get relevant bits of data
					vals = cell2mat({data.(sprintf('%s%s',coord,pop))});
					vals = vals(freqs == sf, :);
					
					[par] = top_straight_line(cell2mat({data.(o_field)}),log(vals),ratio);
					tops(sf_count,co_count,st_count) = par;
				end
			end
		end
		
		% save it for time!
		save(f_name,'tops','stations','ratio');
		
	else
		load(f_name);
		[data,bins] = get_all_psd_data(ddir,stations{1},2000,1); %just get any file for calculating freqs
		freqs = calcfreqs(cell2mat({data(1).x}),data(1).times,[] );
		in_window = freqs >= f_lo & freqs <= f_hi;
		use_freqs  = freqs(in_window);
	end
	
	
	
	% got all the stuff, now plot 
	figure();
	for co_count = [1:length(coords)]
		coord = coords{co_count};
		subplot(length(coords),1,co_count);
		
		for st_count = [1:length(stations)]
			plot(use_freqs,tops(:,co_count,st_count),'.-'); hold on;
		end
		legend(stations);
		ylabel('top bound, log(power)');
		xlabel('freqs, mHz');
		title(sprintf('%s coordinate',coord));
		axis([-inf,inf,min(min(min(tops))),max(max(max(tops)))]);
		
	end
end