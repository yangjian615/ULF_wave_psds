%History
% 15-12-09 No longer spits out GILL_1990_1.m but GILL_sorted3_1990_1.m so
% omni checking is part of preprocessing
% 16-02-03 Save and load files from slightly different location


% Does the thresholding using certain values. After all other processing
% and sorting by hours, so expect to do on many slices.

% Also removes any incomplete slices.
% chunk_length is how long to check for interpolations. I think I've just fed in the number of data points in each window

function [] = do_thresholding( data_dir, station, years, months, z_low_lim, z_high_lim,interpolate_missing, save_removed, window_length,data_t_res,chunk_length )

	if isempty(chunk_length)
		chunk_length = window_length/data_t_res;
	end
    disp('Thresholding data');

	win_mins = window_length/60;
    
    for year = years
        for month = months
            f_to_load = strcat(data_dir,sprintf('/prepped/%s_%d_%d',station,year,month));
            f_to_save = strcat(data_dir,sprintf('/thresholded/%s_%d_%d_%d',station,win_mins,year,month));
            f_to_save2 = strcat(data_dir,sprintf('/thresholded/removed/%s_%d_%d',station,year,month));
            
            
            if exist(strcat(f_to_load,'.mat')) == 2
                word_temp = sprintf('do_thresholding: Doing year %d, month %d',year, month);
                disp(word_temp);
                load(f_to_load); 

             
                
                %if save_removed
                removed = zeros(size(data));
                %end
                
                % remove dataremoved(:,8:10) This should remove the doubled-up hours with bad data
                [data(:,8:10),removed(:,8:10)] = remove_by_threshold(data(:,8:10),z_low_lim,z_high_lim);
                empty_rows = sum(data(:,8:10),2) == 0;
                data(empty_rows,:) = [];
				
				% DUPLICATE DATA CHECK TOO EXPENSIVE? You could just remove it all if two different sets, that usually seems to be the case anyway
				% check for duplicate data, remove if same date different xyz
				[unique_dates,unique_date_indices] = unique(data(:,1));
				if length(unique_dates) ~= length(data)
					warning('>>> You have duplicate data.Checking it <<<');
					extra_data = data;
					extra_data(unique_date_indices,:) = [];
					e_size = size(extra_data);
					dels = false(length(data),1);
					for extra_entry = [1:e_size(1)]
						corresp = data(:,1) == extra_data(extra_entry,1);
						if (sum( data(corresp,8:10) == extra_data(extra_entry) ) ~= 3) % two different sets of data, remove both
							dels(corresp) = true;
						else 
							disp('Some duplicate data. Removing.');
							disp(extra_data);
						end
					end
					if sum(dels) > 1
						disp('Two sets of data for same dates. Removing both sets of data.');
						data = data(~dels,:);
					end
				end
				[unique_dates,unique_date_indices] = unique(data(:,1)); % now getting rid of duplicate data. This will be done again if interpolating, unfortuately
				data = data(unique_date_indices,:);
				
                
                data_size = size(data);
                num_rows = data_size(1);
                % interpolate anything missing if there is data left
                if interpolate_missing & min(data_size) > 0
                    disp('Attempting to interpolate missing data');
					
					% data should already be every five secs so no fancy date checking needed
					to_fix = make_gappy_matrix_by_date(data,5);
					
					warning('Dodgy method for choosing size of gaps to fill!!');
					data = interpolate_fix( to_fix, [8:10], chunk_length, 3*ceil(chunk_length/75) );
					
					% now fill in datevec cols which we left alone
					data(:,2:7) = datevec(data(:,1));
					
                end
                    

				if min(size(data)) > 0 
					save(f_to_save,'data');
				else
					warning('>>> Stuff loaded in but nothing saved out <<<');
				end
                
                if save_removed
                    save(f_to_save2,'removed');
                end
            end
        end
    end


end