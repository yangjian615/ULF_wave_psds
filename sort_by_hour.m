% This function reads in the data and sorts it by hour - it returns the
% data with an extra dimension which is hour (this information is left in
% the matrices, so that the first column in every "slice" should contain
% the same hour with different time)

% We do it month by month.

%HISTORY
%16-01-04 Run even if results file already exists. Still check loading file
%OK.
%16-02-03 Save and load data from slightly different place


function [] = sort_by_hour( data_dir, station, years, months  )
    disp('Sorting by hour');
    
    max_hrs = 33*24;
    temp_data = zeros(720,10,max_hrs);
    data = zeros(365*24*60*60/5 + 1, 10);
    
    for year = years
        for month = months
            %tic
            temp_data(:,:,:) = 0;
            f_to_load = strcat(data_dir,sprintf('/prepped/%s_%d_%d',station,year,month));
            f_to_save = strcat(data_dir,sprintf('/sorted1/%s_%d_%d',station,year,month));
            
            
%             if exist(strcat(f_to_save,'.mat')) == 2
%                 disp('Skipping month - processing already done as file exists');
%             elseif exist(strcat(f_to_load,'.mat')) ~= 2
%                 disp('Skipping month - previous processing level not found');
%             else
            if  exist(strcat(f_to_load,'.mat')) == 2 %& exist(strcat(f_to_save,'.mat')) ~= 2 
                word_temp = sprintf('sort_by_hour: Doing year %d, month %d',year, month);
                disp(word_temp);
                load(f_to_load); %now using matrix 'data'


                data_size = size(data);
                for hour = [1:max_hrs]

                    if min(data_size) > 0        
                        top_lim = 720;

                        if top_lim > data_size(1)
                            top_lim = data_size(1);
                        end
                        %disp(data(1,5));

                        this_hour = data(1:top_lim,5) == data(1,5);
                        hour_data = data(this_hour,:);
                        temp_data(1:sum(this_hour),:,hour) = hour_data;
                        data(this_hour,:) = [];
                        data_size = size(data);
                    end
                end

                if min(size(data)) > 0
                    disp('Not all data used!');
                end

                debug_data = data;

                data = temp_data;
                empty_slices = sum(sum(data(:,:,:))) == 0;
                data(:,:,empty_slices) = [];

                save(f_to_save,'data');
                %toc
            end
        end
    end
end
                    
           

