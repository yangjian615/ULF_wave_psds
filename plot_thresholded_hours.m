% This is to check our threshold is not too small - it will plot anything
% near the threshold, within given limits.  You must supply the limits for
% thresholding and the limits to look at.

% We run through all years and months requested. Then if the data that has
% been thresholded is within a larger limit (which you set) it is all
% plotted (x,y,z,sqrt) so you can see if it was reasonable. You should
% consider making these limits percentage limits.

% You could make this a super clever machine learnin technique if it were
% worthwhile.

% Threshold limits are axis limits for z and sq amp plots.


function [] = plot_thresholded_hours()

    % initial stuff
    station = 'GILL';
    years = [1994];
    months = [7];
    data_dir = strcat(pwd(),'\data\processing\');
    plot_lim = 100;
    
    %threshold values copied over
    %CAREFUL THESE ARE IN TWO PLACES
    z_low = 5.8e4;
    z_high = 6.4e4;
    tot_low = z_low;
    tot_high = z_high;

    %limits to look at/plot thresholded stuff
    bigger_low = 5e4;
    bigger_high = 7e4;

    first_hour = [];
    plot_num = 1;
    for year = years
       if plot_num > plot_lim
            %STOP NOW!
            disp(sprintf('>>>More than %d anomalies<<<',plot_lim));
            return
        end
        for month = months
            if plot_num > plot_lim
                %STOP NOW!
                disp(sprintf('>>>More than %d anomalies<<<',plot_lim));
                return
            end
            this_data = strcat(data_dir,sprintf('%s_sorted2_%d_%d',station, year, month));
            load(this_data);
            disp(sprintf('Plotting only hours just above threshold for %s (minus the data removed)',this_data));
            working = data;
            %working = working(:,:,1:10);

            data_size = size(working);

            x_col = data_size(2) - 2;
            y_col = data_size(2) - 1;
            z_col = data_size(2);

            % dates for first hour - also setup figures
            if min(size(first_hour)) == 0
                first_hour = working(:,1:7,1);      
            end

            
            num_plot_lines = 1;% 5;
            num_plot_cols = 1;% 3;
            plotting = zeros(720,10);
            for i = [1:data_size(3)]
                if plot_num > plot_lim
                    %STOP NOW!
                    disp(sprintf('>>>More than %d anomalies<<<',plot_lim));
                    return
                end
                
                plotting = working(:,:,i);

                % set to first hour of first day
                plotting(:,1:7) = first_hour;
                
                already_empty_rows = sum(plotting,2) == 0;
                plotting_copy = remove_by_threshold( plotting, z_low, z_high );
                removed_rows = sum(plotting_copy,2) == 0;
                
                if sum(removed_rows) > sum(already_empty_rows)
                    to_plot = plotting(~already_empty_rows,:);
                    
                    %check some more:
                    sq_amps = sqrt(to_plot(:,x_col).^2 + to_plot(:,y_col).^2 + to_plot(:,z_col).^2);
                    
                    
                    if all( sq_amps > bigger_low ) & all( sq_amps < bigger_high )
                        %our threshold must have been dubious, so plot!
    
                        disp(sprintf('Anomaly %d: Year %d, month %d, hour-slice %d',plot_num, year, month,i));
                        plot_num = plot_num+1;
                    
                        %figure(); % uncomment this if you want a separate
                        %plot for each anomalous hour.

                        %subplot(4,1,1);
                        figure(1);
                        plot( to_plot(:,1), to_plot(:,x_col),'.' );
                        hold on;  

                        %subplot(4,1,2);
                        figure(2);
                        plot( to_plot(:,1), to_plot(:,y_col),'.' );
                        hold on;  

                        %subplot(4,1,3);
                        figure(3);
                        plot( to_plot(:,1), to_plot(:,z_col),'.' );
                        hold on;  

                        %subplot(4,1,4);
                        figure(4);
                        plot( to_plot(:,1), sqrt((to_plot(:,x_col).^2)+(to_plot(:,y_col).^2)+(to_plot(:,z_col).^2)),'.' );
                        hold on;  




                        
                    end
                end
                

            end

        end
    end
    
    %setup the four figures
    %subplot(4,1,1);
    figure(1);
    dateFormat = 15;
    datetick('x',dateFormat,'keepticks');%,'keeplimits');
    title('X-values');
    xlabel('times');
    ylabel('amplitude nT');

    %subplot(4,1,2);
    figure(2);
    dateFormat = 15;
    datetick('x',dateFormat,'keepticks');%,'keeplimits');
    title('Yvalues');
    xlabel('times');
    ylabel('amplitude nT');

    %subplot(4,1,3);
    figure(3);
    plot( first_hour(:,1), z_low*ones(size(first_hour(:,1))),'r' );         
    plot( first_hour(:,1), z_high*ones(size(first_hour(:,1))),'r' );
    dateFormat = 15;
    datetick('x',dateFormat,'keepticks');%,'keeplimits');
    axis([-inf,inf,bigger_low,bigger_high]); %could use z_low.z_high
    title('Z-values');
    xlabel('times');
    ylabel('amplitude nT');

    %subplot(4,1,4);
    figure(4);
    plot( first_hour(:,1), tot_low*ones(size(first_hour(:,1))),'r' );         
    plot( first_hour(:,1), tot_high*ones(size(first_hour(:,1))),'r' );
    dateFormat = 15;
    datetick('x',dateFormat,'keepticks');%,'keeplimits');
    axis([-inf,inf,bigger_low,bigger_high]); %could use tot_low,tot_high
    title('Squared amplitude values');
    xlabel('times');
    ylabel('amplitude nT');

end
