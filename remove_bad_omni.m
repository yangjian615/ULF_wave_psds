% History
% 15-12-09 Created
% 15-12-18 Finished
% 16-02-03 Save data in slightly different folder

% Receives GILL_sorted3_1990_1 etc and spits out GILL_1990_1 (containing "data" and "mini_omni") where any corresponding bad omni data is removed. 
% Bad omni data should have been removed when read in. We now need to
% remove any data that does NOT have corresponding omni data for that hour

function [] = remove_bad_omni( data_dir,station,years,months)

    
    load(strcat(data_dir,sprintf('%s_omni',station)));
    omni_all = omni_data; %manyx4: DATENUM      SW SPEED        Kp VALUE        E-AMPLITUDE Note the datenum should be for the very beginning of that hour.
    omni_size = size(omni_data);


    % now get and use the parts for each month
    for year = years
        for month = months
            mini_omni = [];
            word_temp = sprintf('remove_bad_omni: Doing year %d, month %d',year, month);
            disp(word_temp);
            f_to_open = strcat(data_dir,sprintf('/sorted2/%s_%d_%d',station,year,month));
            f_to_save = strcat(data_dir,sprintf('/ready/%s_%d_%d',station,year,month));
            load(f_to_open);
            
            [y m d h] = datevec( data(1,1,:) );
            hour_dates = datenum( [y' m' d' h' zeros(size(y))' zeros(size(y))']  );
            
            [y m d h ] = datevec( omni_data(:,1) );
            omni_dates = datenum( [y m d h zeros(size(y)) zeros(size(y))]  );
            
            mini_omni = zeros( length(hour_dates), 4);
            
            for i = [1:length(hour_dates)]
                this_hour = hour_dates(i);
                matching = omni_dates == this_hour;
                if sum( matching ) == 1
                    mini_omni( i,1:4 ) = omni_data( matching,1:4);
                end
            end
        
            % now find whether any rows are zero in mini_omni
            zeroes = sum(mini_omni,2) == 0;
            
            % remove these
            mini_omni( zeroes,: ) = [];
            data(:,:,zeroes) = [];
            
           % save the data
           save(f_to_save,'data','mini_omni');
            
            
        end
    end


end
