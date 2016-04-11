% Several optional stages: Calculate the PSD, find the median of these, and
% plot it. Finding the median and plotting is sorted by SW speed bin and
% day sector.

% You can specify whether you want to plot the psd ('psd') or the power spectrum ('ps').

% 16-01-04 MInor graph label changes
% 16-01-06 Other graph changes
% 16-01-29 PLot unsorted medians
% 16-02-01 MOre stuff returned from get_psd_medians. Not using it yet.
% 16-02-02 Plot information returned about the data

function [] = plotting_and_psds(data_dir,station,years,months,sort_type,ps_or_psd,plot_info)

	jonny_correction_factor = false; % do you want your PSDS to look like Jonnys?
	
    % station = 'GILL';
    % years = [1990:2004];
    % months = [1:12];
    % data_dir = strcat(pwd,sprintf('/data/'));
    
    % calc_psds = false; 
	% sort_type = 'speed';
    plot_medians = true;
    % plot_info = false; %tell us how much data we used!
    
    %set up variables
    ts = 5; %5s between samples
    N = 720; %no. samples in each slice (an hour)
    f_max = 1/ts; 
    f_nyquist = f_max/2; %Nyquist frequency
    f_res = 1/(N*ts); %frequency resolution
    n = [0:N];
    plot_end = (N/2);
    freqs = (f_max/(N))*n*(1e3); %in mHz 
    day_ranges = [ 3, 9 ; 9, 15; 15, 21 ;21,3];
    
    axis_lim = [];%[0.75,14,0.5,0.9e5];%-inf,inf];%[0.75,14,0,1.5e5];%[0.75,14,0.4e-4,0.9e3];
    xlabel_words = 'Freq, mHz';
	ylabel_words = [];
	if strcmp(ps_or_psd,'psd')
		ylabel_words = 'PSD, (nT)^2 mHz^{-1}'; % / mHz';
		axis_lim = [0.75,14,1.9e2,0.99e9];
	else if  strcmp(ps_or_psd,'ps')
		ylabel_words = 'Power, (nT)^2';
		axis_lim = [0.75,14,0.5,0.9e5];
	else
		error('>>> PS or PSD?? <<<');
	end
    
    output_info = [];
	disp(sprintf('Plotting and psds options: sort type %s, %s, plot the data spread %d',sort_type,ps_or_psd,plot_info));
	
    
    if strcmp(sort_type,'no_sort')

		disp('Finding unsorted medians over requested data');
		[meds,bins,output_info,hrs,dys] = get_psd_medians(data_dir,station,years, months,sort_type,ps_or_psd);

        
        if plot_medians
            loglog(freqs(1:plot_end),meds(:,1));
            xlabel(xlabel_words);
            title_words = sprintf('%s medians of x co-ord',station);
            title(title_words);
            axis(axis_lim);
            %axis([0.75,14,-inf,inf]);
            disp('Only rough code completed for plotting unsorted median PSD values');
        end
        
        if plot_info 
            figure();
            bar(output_info,'grouped');
            title('Amount of data used to find each median');
            plot_data_spread(dys,hrs,ones(size(hrs)),'Days used');
        end
		
    else
		disp('Finding medians over requested data');
		[meds,bins,output_info,hrs,dys,spd] = get_psd_medians(data_dir,station,years, months,sort_type,ps_or_psd);
		if jonny_correction_factor
			meds = (1/N^2)*meds;
		end
		
        if plot_medians

            num_meds = size(meds);

			% set up for the big plot
            h = figure('units','normalized','outerposition',[0 0 1 1]);
            set(h,'units','pixels','Position',[50, 100, 1100, 800]);
            set(h,'PaperType','a4');
            set(h,'PaperPositionMode','auto');
            set(h,'PaperOrientation','landscape');
            %set(h,'PaperUnits','normalized');
            %set(h,'PaperPosition',[0.2 0.2 5 5])'
            rows = 3;
            cols = 6;
            space = 0;
			
            plot_posns = [14 7 2 9 17 10 5 12]; % Title location, then X posns for each sector, then Y posns for each sector
			ax = getCustomAxesPos(rows,cols, plot_posns,space);

            for i = [1 2] %each index X, Y
                for sector = [1:num_meds(3)]                    
                    plot_pos = plot_posns(sector+(i-1)*num_meds(3));

                    for each_bin = [1 : num_meds(4)] 
                        these_meds = meds(2:plot_end,i,sector,each_bin);
                        loglog(ax(plot_pos),freqs(2:plot_end),these_meds);
                        hold(ax(plot_pos),'on');

                    end
                end
            end
			
			
			%set up the legend
			bin_units = {};
			if strcmp(sort_type,'speed')
				bin_units = 'km/s';
			else 
				bin_units = '???';
			end
			the_bins{1} = strcat('< ',num2str(bins(1)),bin_units); 
			for k = [1:length(bins)-1]
				the_bins{k+1} = strcat(num2str(bins(k)),' - ',num2str(bins(k+1)),bin_units);
			end
			the_bins{length(bins)+1} = strcat('> ',num2str(bins(length(bins))),bin_units);			
			legend(ax(plot_posns(length(plot_posns))),the_bins,'Position',[0.75 0.11 0.15 0.15]);%'Location','bestoutside');
            legend('boxoff')
			
			% not quite a title!
			title_str = {sprintf('Median PSDs/power spectra for %s',station) 'years:' num2str(years) 'months:' num2str(months) 'binned by:' sort_type };
			annotation('textbox',[0.05 0.7 0.2 0.2],'String',title_str);%,'FitBoxToText','on');
			

            % label the graphs
            for j = [1:numel(plot_posns)]
                sector =  mod(j,4);
				if sector == 0
					sector = 4;
				end
                this_ax = ax(plot_posns(j));
                x1 = axis_lim(1)+0.1*log(axis_lim(2)-axis_lim(1));
                y1 = axis_lim(3)+0.1*log(axis_lim(4)-axis_lim(3));
				if strcmp(ps_or_psd,'psd')
					x1 = 1.1;%
					y1 = 1e3;
				end
                title_words = ' ';
                halign = ' ';

                if ceil((j)/4) == 1
                    component = 'X';%'H';%
                    title_words = 'Day sector:';
                    halign = 'center';
                    if j ~= 1
                        ylabel(this_ax,ylabel_words);
                    end

                else
                    component = 'Y';%'D';%
                    title_words = sprintf('MLT %d - %d',day_ranges(sector,1),day_ranges(sector,2));
                    halign = 'right';

                end
                %grid(ax(plot_posns(j)), 'on');
                xlabel(this_ax,xlabel_words);
                set(this_ax,'XTick',[1 10]);
                axis(this_ax,axis_lim);
                text(x1,y1,component,'Parent',this_ax);
                title(this_ax,title_words,'HorizontalAlignment',halign);

            end
			
			%saveas(h,sprintf('%s_%s_%s',station,num2str(years),sort_type),'pdf');

        end
        if plot_info
            
            figure();
            bar(output_info,'grouped');
            legend(the_bins,'Location','northwest');
            title('Amount of data used to find each median');
            MLTs = {sprintf('MLT %d - %d',day_ranges(1,1),day_ranges(1,2)),sprintf('MLT %d - %d',day_ranges(2,1),day_ranges(2,2)),sprintf('MLT %d - %d',day_ranges(3,1),day_ranges(3,2)),sprintf('MLT %d - %d',day_ranges(4,1),day_ranges(4,2))};
            set(gca,'XTickLabel', MLTs);
            
            plot_data_spread(dys,hrs,spd,'Data used at each hour, with SW speed bin');
		end
                    
    end
    
end