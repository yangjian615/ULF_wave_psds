% Several optional stages: Calculate the PSD, find the median of these, and
% plot it. Finding the median and plotting is sorted by SW speed bin and
% day sector.

% 16-01-04 MInor graph label changes
% 16-01-06 Other graph changes
% 16-01-29 PLot unsorted medians
% 16-02-01 MOre stuff returned from get_psd_medians. Not using it yet.
% 16-02-02 Plot information returned about the data

function [] = plotting_and_psds()

    station = 'SP01';
    years = [2001];%[1990:2004];
    months = [11];%[1:12];
    data_dir = strcat(pwd,sprintf('/data/'));
    
    calc_psds = false;%true;
    find_medians = true;
    sort_medians = false; % do we want them sorted by sector and SW speed?
    plot_medians = true;
    plot_info = true; %tell us how much data we used!
    
    %set up variables
    ts = 5; %5s between samples
    fs = 1/ts; 
    N = 720; %no. samples in each slice (an hour)
    n = [0:N];
    plot_end = (N/2);
    freqs = (fs/(N))*n*(1e3); %in mHz 
    day_ranges = [ 3, 9 ; 9, 15; 15, 21 ;21,3];
    
    axis_lim = [0.75,14,0.4e-4,0.9e3];%[0.9,11,0.9e-4, 0.9e3];
    xlabel_words = 'Freq, mHz';
    ylabel_words = 'PSD, (nT)^2 / mHz';
    
    SW_bins = {'v < 300 km/s', '300-400 km/s','400-500 km/s', '500-600 km/s','600-700 km/s', 'v > 700 km/s'};
    output_info = [];
    
    if calc_psds        
        disp('Calculating PSDs');
        calculate_psds(data_dir, station, years, months,fs );
    end
    
    if ~sort_medians
        if find_medians
            disp('Finding unsorted medians over requested data');
            [meds, output_info,hrs,dys] = get_psd_medians(data_dir,station,years, months,zeros(4,2));
        end
        
        if plot_medians
            loglog(freqs(1:plot_end),meds(:,1));
            xlabel(xlabel_words);
            title_words = sprintf('%s medians of x co-ord',station);
            title(title_words);
            axis(axis_lim);
            disp('Only rough code completed for plotting unsorted median PSD values');
        end
        
        if plot_info 
            figure();
            bar(output_info,'grouped');
            %legend(SW_bins,'Location','northwest');
            title('Amount of data used to find each median');
            %MLTs = {sprintf('MLT %d - %d',day_ranges(1,1),day_ranges(1,2)),sprintf('MLT %d - %d',day_ranges(2,1),day_ranges(2,2)),sprintf('MLT %d - %d',day_ranges(3,1),day_ranges(3,2)),sprintf('MLT %d - %d',day_ranges(4,1),day_ranges(4,2))};
            %set(gca,'XTickLabel', MLTs);
            
            plot_data_spread(dys,hrs,ones(size(hrs)),'Days used');
        end
        
    elseif sort_medians
    
        if find_medians
            disp('Finding medians over requested data');
            [meds, output_info,hrs,dys,spd] = get_psd_medians(data_dir,station,years, months,day_ranges);
        end

        if plot_medians

            num_meds = size(meds);

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


            plot_posns = [ 14 7 2 9;17 10 5 12]; % the Xs for each day range, then the Ys
            ax = getCustomAxesPos(rows,cols, plot_posns,space);

            for i = [1 2] %each index X, Y
                for sector = [1:num_meds(3)]              
                    plot_pos = plot_posns(i,sector);

                    for SW_bin = [1 : num_meds(4)] 
                        these_meds = meds(1:plot_end,i,sector,SW_bin);
                        loglog(ax(plot_pos),freqs(1:plot_end),these_meds);
                        hold(ax(plot_pos),'on');

                    end
                    %plot(ax(plot_pos),10,1e-4,'o');
                end
            end
            legend(ax(plot_posns(2,2)),SW_bins(1:num_meds(4)),'Position',[0.75 0.11 0.15 0.15]);%'Location','bestoutside');
            legend('boxoff')


            % label the graphs

            for j = [1:numel(plot_posns)]
                sector =  ceil(j/2);
                this_ax = ax(plot_posns(j));
                x1 = 1;
                y1 = 1.5e-4;
                title_words = ' ';
                halign = ' ';

                if mod(j,2) == 1
                    component = 'X';
                    title_words = 'Day sector:';
                    halign = 'center';
                    if j ~= 1
                        ylabel(this_ax,ylabel_words);
                    end

                else
                    component = 'Y';
                    title_words = sprintf('MLT %d - %d',day_ranges(sector,1),day_ranges(sector,2));
                    halign = 'right';

                end
                %grid(ax(plot_posns(j)), 'on');
                xlabel(this_ax,xlabel_words);
                set(this_ax,'XTick',[1 10]);
                axis(this_ax,axis_lim);
                text(x1,y1,component,'Parent',this_ax);
                title(this_ax,title_words,'HorizontalAlignment',halign);

                %saveas(h,'most_recent','pdf');
            end

        end
        if plot_info
%             figure();
%             for i = [1:4]
%                 subplot(2,2,i);
%                 bar(output_info(i,:));
%                 title_words = sprintf('MLT %d - %d',day_ranges(i,1),day_ranges(i,2));
%                 title(title_words);
%                 set(gca,'ylim',[0,round(max(max(output_info)),1,'significant')]);
%                 set(gca,'XTickLabel', SW_bins);
%                 set(gca,'XTickLabelRotation',45);
%                 %ax = axis; 
%                 %ax.XTickLabel = SW_bins; Is this the version you'd use for
%                 %later releases?
%                 %ax.XTickLabelRotation=45;
%             end
            
            figure();
            bar(output_info,'grouped');
            legend(SW_bins,'Location','northwest');
            title('Amount of data used to find each median');
            MLTs = {sprintf('MLT %d - %d',day_ranges(1,1),day_ranges(1,2)),sprintf('MLT %d - %d',day_ranges(2,1),day_ranges(2,2)),sprintf('MLT %d - %d',day_ranges(3,1),day_ranges(3,2)),sprintf('MLT %d - %d',day_ranges(4,1),day_ranges(4,2))};
            set(gca,'XTickLabel', MLTs);
% % %             
% % %             figure();
% % %             [Y,X] = meshgrid(0:23,min(dys):max(dys));
% % %             Z = NaN(max(dys)-min(dys)+1,24);
% % %             %run through hrs, dys to put in real data
% % %             for i =[1:length(hrs)]
% % %                 xval = dys(i);
% % %                 yval = hrs(i);
% % %                 zval = spd(i);
% % %                  
% % %                 location = X == xval & Y == yval;
% % %                 Z(location) = zval;
% % %             end
% % %             surf(X,Y,Z);
% % %             view(2);
% % %             shading flat;
% % %             %view(90,0); %against yz plane
% % %             set(gca,'ylim',[0 24.5]);
% % %             %legend(SW_bins);
% % %             datetick('x',22);
% % %             title('Data used at each hour, with SW speed bin');
            
            plot_data_spread(dys,hrs,spd,'Data used at each hour, with SW speed bin');
                    
            %hold on;
            %scatter(dys,hrs,'.');
            %hold on;
            %mesh(min(hrs):max(hrs),0:23);
%             tri = delaunay(dys,hrs);
%             trisurf(tri,dys,hrs,spd);
%             %surf(dys,hrs,spd);
%             view(2);
    end
    
end