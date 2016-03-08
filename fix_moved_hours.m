% This function moves across bits into the correct month (problems from
% converting to MLT!

% We move BACKWARDS (starting witha more recent month then going to the
% previous)

% This should ALWAYS run backwards on all files for a given station.

% History
% 16-02-03 Save and load files from slightly different location

function [] = fix_moved_hours( data_dir, station )
    disp('Glueing together hours split when converting to MLT');
    
    extra_data = [];
    for year = [2005:-1:1990]
        for month = [12:-1:1]
            f_to_load = strcat(data_dir,sprintf('/sorted1/%s_%d_%d',station,year,month));
            f_to_save = strcat(data_dir,sprintf('/sorted2/%s_%d_%d',station,year,month));
            
%             if exist(strcat(f_to_load,'.mat')) ~= 2 
%                 disp('File nonexistent. Skip this month.');
%             else
            if exist(strcat(f_to_load,'.mat')) == 2 
                word_temp = sprintf('fix_moved_hours: Doing year %d, month %d',year, month);
                disp(word_temp);
                load(f_to_load); %now using matrix 'data'

                % first stick on the bits that were wrong
                if min(size(extra_data)) > 0
          
                    old_data_size = size(data);
                    extra_data_size = size(extra_data);
                    earlier_month_last_hour = data(:,:,old_data_size(3));

                    later_month_first_hour = extra_data(:,:,1);

                    
                    %check they are the same hour
                    [y m d h] = datevec(later_month_first_hour(1,1));
                    later_hour = datenum([y m d h zeros(size(y)) zeros(size(y))]);
                    
                    [y m d h] = datevec(earlier_month_last_hour(1,1));
                    earlier_hour = datenum([y m d h zeros(size(y)) zeros(size(y))]);
                    %disp(datetime(datevec(later_hour))); disp(datetime(datevec(earlier_hour)));
                    
                    if later_hour ~= earlier_hour
                        disp('>>> THEY ARE NOT THE SAME HOUR <<<');
                        disp('Dont move this hour');
                    else
                    
                        % check they add up properly
                        num_later_entries = sum( sum(later_month_first_hour,2) ~= 0 );
                        num_earlier_entries = sum( sum(earlier_month_last_hour,2) ~= 0 );
                        split_slice_entries = num_earlier_entries + num_later_entries;
                        if  split_slice_entries < 720
                            later_month_entries = sprintf('The later month has %d nonzero entries its first hour, found from extra_data', num_later_entries);
                            earlier_month_entries = sprintf('The earlier month has %d nonzero entries in its last hour',num_earlier_entries);
                            disp(later_month_entries);
                            disp(earlier_month_entries);
                            disp('Not enough data in split slice, not glueing the very first slice');
                        elseif split_slice_entries > 720
                            later_month_entries = sprintf('The later month has %d nonzero entries its first hour, found from extra_data', num_later_entries);
                            earlier_month_entries = sprintf('The earlier month has %d nonzero entries in its last hour',num_earlier_entries);
                            disp(later_month_entries);
                            disp(earlier_month_entries);
                            disp('>>>TOO MUCH DATA, UNKNOWN REASON<<<');
                        else %stick together the split-up end hour if it adds up ok
                            temp = earlier_month_last_hour;
                            temp(num_earlier_entries+1:720,:) = later_month_first_hour(1:num_later_entries,:);
                            data(:,:,old_data_size(3)) = temp;
                        end
                    end

                    %stick on all other (full) hour slices if there are any
					if length(extra_data_size) > 2
						temp_data = zeros(720,10,old_data_size(3)+extra_data_size(3)-1);
						temp_data(:,:,1:old_data_size(3)) = data;
						temp_data(:,:,old_data_size(3)+1 : old_data_size(3) + extra_data_size(3) -1) = extra_data(:,:,2:extra_data_size(3));
						data = temp_data;
					end
                else
                    disp('Nothing to move between files');
                end


                % take off the bits that are still wrong
                wrong_month = data(1,3,:) ~= month;
                extra_data = data(:,:,wrong_month);
                data(:,:,wrong_month) = [];

                save(f_to_save,'data');
            end
        end
    end


end
