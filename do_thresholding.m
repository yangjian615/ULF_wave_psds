%History
% 15-12-09 No longer spits out GILL_1990_1.m but GILL_sorted3_1990_1.m so
% omni checking is part of preprocessing
% 16-02-03 Save and load files from slightly different location


% Does the thresholding using certain values. After all other processing
% and sorting by hours, so expect to do on many slices.

% Also removes any incomplete slices.


function [] = do_thresholding( data_dir, station, years, months, z_low_lim, z_high_lim, save_removed )
    disp('Thresholding data');

    
    temp_slice = zeros(720,10);
    for year = years
        for month = months
            f_to_load = strcat(data_dir,sprintf('/sorted2/%s_%d_%d',station,year,month));
            f_to_save = strcat(data_dir,sprintf('/sorted3/%s_%d_%d',station,year,month));
            f_to_save2 = strcat(data_dir,sprintf('/sorted3/removed/%s_%d_%d',station,year,month));
            
            
%             if exist(strcat(f_to_load,'.mat')) ~= 2
%                 disp('Skipping month - previous processing level not found');
%             else
            if exist(strcat(f_to_load,'.mat')) == 2
                word_temp = sprintf('do_thresholding: Doing year %d, month %d',year, month);
                disp(word_temp);
                load(f_to_load); %now using matrix 'data'

                data_size = size(data);
                num_slices = data_size(3);
                
                if save_removed
                    removed = zeros(size(data));
                end

                empty_rows = zeros(num_slices,1);
                for i = [1:num_slices]
                    temp_slice = data(:,:,i);
                    [data(:,:,i),removed(:,:,i)] = remove_by_threshold(temp_slice,z_low_lim,z_high_lim);

                    empty_row_count = sum( sum( data(:,:,i),2 ) == 0);
                    empty_rows(i) = empty_row_count;
                end

                % then remove any slices with empty rows (can change no. of
                % rows missing if desired)
                data(:,:, empty_rows > 0 ) =[];

                save(f_to_save,'data');
                
                if save_removed
                    save(f_to_save2,'removed');
                end
            end
        end
    end


end