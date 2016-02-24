%History
% 15-12-09 No longer spits out GILL_1990_1.m but GILL_sorted3_1990_1.m so
% omni checking is part of preprocessing
% 16-02-03 Save and load files from slightly different location


% Does the thresholding using certain values. After all other processing
% and sorting by hours, so expect to do on many slices.

% Also removes any incomplete slices.


function [] = do_thresholding( data_dir, station, years, months, z_low_lim, z_high_lim,interpolate_missing, save_removed )
    disp('Thresholding data');

    
    for year = years
        for month = months
            f_to_load = strcat(data_dir,sprintf('/prepped/%s_%d_%d',station,year,month));
            f_to_save = strcat(data_dir,sprintf('/thresholded/%s_%d_%d',station,year,month));
            f_to_save2 = strcat(data_dir,sprintf('/thresholded/removed/%s_%d_%d',station,year,month));
            
            
%             if exist(strcat(f_to_load,'.mat')) ~= 2
%                 disp('Skipping month - previous processing level not found');
%             else
            if exist(strcat(f_to_load,'.mat')) == 2
                word_temp = sprintf('do_thresholding: Doing year %d, month %d',year, month);
                disp(word_temp);
                load(f_to_load); %now using matrix 'data'

             
                
                %if save_removed
                removed = zeros(size(data));
                %end
                
                % remove dataremoved(:,8:10)
                [data(:,8:10),removed(:,8:10)] = remove_by_threshold(data(:,8:10),z_low_lim,z_high_lim);
                empty_rows = sum(data(:,8:10),2) == 0;
                data(empty_rows,:) = [];
                
                
                data_size = size(data);
                num_rows = data_size(1);
                % interpolate anything missing
                if interpolate_missing
                    disp('Attempting to interpolate missing data');
                    max_month_size = 32*24*60*60/5; %got to start earlier as rotated to MLT, also have to have every second not just every five due to data
                    to_fix = nan(max_month_size+num_rows,10);
                    fixed = nan(max_month_size,10);
                    
                    to_fix(1:num_rows,:) = data;
                    indices = [1:max_month_size];
                    
                    basis = ones(max_month_size,1);
                    y = year*basis;
                    m = month*basis;
                    d = 0*basis;
                    h = 0*basis;
                    min = 0*basis;
                    s = [0:max_month_size-1]'*5; %have to have every second not every five for mismatches when resetting data
                    

                    % stickk all the datenums together, ones from data
                    % first
                    to_fix(num_rows+1:num_rows+max_month_size,1) = datenum([y m d h min s]);
                    to_fix = sortrows(to_fix,1);
                    
                    % only keep unique ones
                    [unique_dates,unique_date_indices] = unique(to_fix(:,1));
                    fixed = to_fix(unique_date_indices,:);

                    % check size
                    if max(size(fixed)) ~= max_month_size
                        disp(size(fixed));
                        error('>> You havent got the right size matrix <<');
                    end
                    
                    % cut off beginning and end, change value of
                    % max_month_size accordingly
                    cut_off_index = 1;
                    while sum(isnan(fixed(cut_off_index,:))) >0 %will break as soon as bigger than fixed
                        cut_off_index = cut_off_index +1;
                    end
                    fixed_length = max_month_size;
                    while sum(isnan(fixed(fixed_length,:))) > 0
                        fixed_length = fixed_length - 1;
                    end
                    fixed = fixed(cut_off_index:fixed_length,:);
                    
                    % find bad places
                    good_data = ~isnan(fixed(:,8:10));
                    try_fix = ~good_data; % will now only do it if not too many in an hour
                    
                    
                    % see whether wort attempting to fix
                    for i = [1:floor(fixed_length/720)]
                        endpoint = min( [720*(i) fixed_length] );
                        hr_indices = [720*(i-1)+1:endpoint];
                        if sum(sum(try_fix(hr_indices,:))) > 30
                            try_fix(hr_indices,:) = false;
                        end
                    end
                    
                    disp(sprintf('Trying to fix %d data points this month',sum(sum(try_fix))));
                    
       
                    % fix it
                    for i = [1:3]
                        col = i+7;
                        this_try_fix = try_fix(:,i);
                        this_good_data = good_data(:,i);
                        fixed(this_try_fix,col) = interp1(indices(this_good_data),fixed(this_good_data,col),indices(this_try_fix));
                        fixed(this_try_fix,2:7) = datevec(fixed(this_try_fix,1)); 
                    end

                    
                    gappy_data = sum(isnan(fixed(:,8:10)),2);
                    data = fixed(~gappy_data,:);
                   
                end
                    


                save(f_to_save,'data');
                
                if save_removed
                    save(f_to_save2,'removed');
                end
            end
        end
    end


end