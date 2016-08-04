% This function moves across bits into the correct month (problems from
% converting to MLT!

% We move BACKWARDS (starting witha more recent month then going to the
% previous) since the month has been shifted baclkwards by six hours. This 
% means that some stuff at the very beginning of the month is now at the very end of 
% earlier month. So this needs to be chopped off (saved in extra_data) and 
% stuck on the end of the correct month file. Care must be taken for sticking 
% together hours that are split in half.

% This should ALWAYS run backwards on all files for a given station.


% Slices are still called "hours" even though window length is now variable.


function [] = fix_moved_hours( data_dir, station, data_opts, data_t_res )

	ptag = get_ptag();


    do_print(ptag,1,'fix_moved_hours: Glueing together hours split when converting to MLT \n');
    
	win_mins = data_opts.win_mins;
	window_length = win_mins*60;
	window_data_num = window_length/data_t_res;

	
    extra_data = [];
    for year = 2005:-1:1990
        for month = 12:-1:1
            f_to_load = strcat(data_dir,sprintf('/sorted1/%s_%d_%d_%d',station,win_mins,year,month));
            f_to_save = strcat(data_dir,sprintf('/sorted2/%s_%d_%d_%d',station,win_mins,year,month));
            

            if exist(strcat(f_to_load,'.mat'),'file')
                do_print(ptag,2,sprintf('fix_moved_hours: Doing year %d, month %d\n',year, month));
                load(f_to_load); % load in data

				% check that the extra data is of this month
			 	if min(size(extra_data)) > 0
					check_month = extra_data(1,3,:) == month;
					extra_data = extra_data(:,:,check_month);
					
					if sum(check_month) ~= length(check_month)
						warning('fix_moved_hours:ExtraDataWrongMonth','Wrong month in extra data, didnt expect');
					end
				end
				
                % Take the extra data from previous run of loop, add to correct month
                if min(size(extra_data)) > 0
					
					%% Look at the ends of each, can they stick together?
                    earlier_month_last_hour = data(:,:,end);
                    later_month_first_hour = extra_data(:,:,1);

                    
                    % check they are in same window
                    t_diff = abs(etime(datevec(later_month_first_hour(1,1)),datevec(earlier_month_last_hour(1,1))));
                    
					
                    if t_diff >= window_length
						% Different window so no splicing together.
                        do_print(ptag,3,'fix_moved_hours: Part-slices from different windows, dont glue\n');
                    else
						% Same window but must check they fill an entire window before adding.
						% Remove ends if part-full after if statement.
						do_print(ptag,3,sprintf('fix_moved_hours: fixing %s\n',char(datetime(datevec(earlier_month_last_hour(1,1))))));
                    
                        num_later_entries = sum( sum(later_month_first_hour,2) ~= 0 );
                        num_earlier_entries = sum( sum(earlier_month_last_hour,2) ~= 0 );
                        split_slice_entries = num_earlier_entries + num_later_entries;
                        if  split_slice_entries < window_data_num
                            do_print(ptag,3,sprintf('fix_moved_hours: Not enough data in split slice, only %d points overall, not glueing the very first slice\n',split_slice_entries));
                        elseif split_slice_entries > window_data_num
							do_print(ptag,1,sprintf('problem time: %s with %d good entries\n',char(datetime(datevec(earlier_month_last_hour(1,1)))),num_earlier_entries));
							do_print(ptag,1,sprintf('problem time: %s with %d good entries\n',char(datetime(datevec(later_month_first_hour(1,1)))),num_later_entries));	
                            error('fix_moved_hours:TooMuchData','>>>TOO MUCH DATA, UNKNOWN REASON<<<');
                        else %stick together the split-up end hour if it adds up ok
                            temp = earlier_month_last_hour;
                            temp(num_earlier_entries+1:window_data_num,:) = later_month_first_hour(1:num_later_entries,:);
                            data(:,:,end) = temp; % removal of used extra_data should be below.
							clearvars('temp');
                        end
                    end
					
					%% YOU NEED TO CHECK THE TIME RESOLUTION, ESPECIALLY FOR THE FIXED ONE.
					
					% check latest window for data is full and earliest for extra data
					latest_win = data(:,8:end,end);
					if sum( sum(latest_win,2) == 0 ) > 0
						do_print(ptag,3,sprintf('fix_moved_hours: last window in data is too empty, removing part-slice %s\n',char(datetime(datevec(data(1,1,end))))));
						data = data(:,:,1:end-1);
					end
					earliest_extra_win = extra_data(:,8:end,1);
					if sum( sum(earliest_extra_win,2) == 0 ) > 0
						do_print(ptag,3,sprintf('fix_moved_hours: first window in extra data is too empty, removing part-slice %s\n',char(datetime(datevec(extra_data(1,1,1))))));
						extra_data = extra_data(:,:,2:end);
					end

					
                    %stick on all other (full) hour slices if there are any
					if size(extra_data,3) > 0
						temp_data = zeros(window_data_num,10,size(data,3)+size(extra_data,3)-1);
						temp_data(:,:,1:size(data,3)) = data;
						temp_data(:,:,size(data,3)+1 : size(data,3) + size(extra_data,3) ) = extra_data(:,:,1:end);
						data = temp_data;
						
					end
                else
                    do_print(ptag,3,'Nothing to move between files - still need to check end of month\n');
                end

				% Check very first window is full and check latest window is full (
				% This check is here because either no check performed before or now recheck for new ends needed
				first_win = data(:,8:10,1);
				if sum( sum(first_win,2) == 0 ) > 0
					data = data(:,:,2:end);
				end
				last_win = data(:,8:10,end);
				if sum( sum(last_win,2) == 0 ) > 0
					data = data(:,:,1:end-1);
				end
				%% NOTE: It would be better to just check everything but would also cost far more so we don't do that.
				
                % Find anything in the wrong month
                wrong_month = data(1,3,:) ~= month;
				clearvars('extra_data'); %Refresh, don't keep any of old esxtra data
                extra_data = data(:,:,wrong_month);

				% NOTE: a check fo all hours, shouldn't be necessary but may be useful.
				%for data_ind = 1:size(data,3)
				%	 if ~wrong_month(data_ind)
				%		 first_slice = data(:,8:end,data_ind);
				%		 if sum( sum(first_slice,2) == 0 ) > 0
				%			 error('fix_moved_hours: window-index %d is too empty, removing part-slice %s\n',data_ind,char(datetime(datevec(data(1,1,1)))));
				%			 wrong_month(data_ind) = true;
				%		 end
				%	 end
				%end
				
				% Remove stuff from wrong month
				data = data(:,:,~wrong_month);
				earliest_hour = data(:,:,1);
				if sum( sum(earliest_hour,2) == 0 ) > 0
					warning('fix_moved_hours:StillNonFullSlice','First hour in month still not full!');
					data = data(:,:,2:end);
				end

				
                save(f_to_save,'data','-v7.3');
            end
        end
    end


end
