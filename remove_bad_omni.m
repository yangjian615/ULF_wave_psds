% History
% 15-12-09 Created
% 15-12-18 Finished
% 16-02-03 Save data in slightly different folder

% Receives GILL_sorted3_1990_1 etc and spits out GILL_1990_1 (containing "data" and "mini_omni") where any corresponding bad omni data is removed. 
% Bad omni data should have been removed when read in. We now need to
% remove any data that does NOT have corresponding omni data for that hour

function [] = remove_bad_omni( data_dir,station,years,months,window_length)

	win_mins = window_length/60;
	one_omni = mod(window_length,60^2) == 0

    if one_omni
		load(strcat(data_dir,sprintf('%s_omni_%d',station,win_mins)));
		omni_all = omni_data; 
		omni_size = size(omni_data);
	end


    % now get and use the parts for each month
    for year = years
        for month = months
            mini_omni = [];
            f_to_open = strcat(data_dir,sprintf('sorted2/%s_%d_%d_%d',station,win_mins,year,month));
			if exist(strcat(f_to_open,'.mat')) ~= 2
				warning(sprintf('>>> Could not load file <<< %s',f_to_open));
			else
				f_to_save = strcat(data_dir,sprintf('structured/%s_%d_%d_%d',station,win_mins,year,month));
				word_temp = sprintf('remove_bad_omni: Doing year %d, month %d for %d minute windows',year, month,win_mins);
				disp(word_temp);
				load(f_to_open);
				
				if ~one_omni
					fomni_to_load = strcat(data_dir,sprintf('omni_1min/sorted1/%s_omni_1min_%d_%d_%d',station,win_mins,year,month));
					load(fomni_to_load);
				end
				
				[y m d h mins secs] = datevec( data(1,1,:) ); %converting omni hour dates for me to use. This will change if OMNI hourss change
				hour_dates = datenum( [y' m' d' h' mins' secs']  );
				
				omni_dates = cell2mat({omni_data.dates});
				
				%disp(datetime(datevec(omni_dates(1:5))));
				%disp(datetime(datevec(hour_dates(1:5))));
				
				% set up structures, including length of data
				data_s = struct( 'dates',[],'times',[],'x',[],'y',[],'z',[] );
				data_bins = struct();
				dates_for_struct = num2cell(hour_dates);
				%[data_s.dates] = dates_for_struct{:};
				
				% get omni field names
				omni_fields = fieldnames(omni_data);
				mini_fields = {};
				for f_ind = [2:length(omni_fields)] %don't need to include dates fields
					fn = char(omni_fields(f_ind));
					data_bins(f_ind-1).of_name = fn;
				end
				
				entry = 1;
				dels = false(1,length(hour_dates));
				for hr_ind = [1:length(hour_dates)]
					%entry = i;
					this_hour = hour_dates(hr_ind);
					matching = omni_dates == this_hour;
					if sum( matching ) == 1
						data_s(entry).dates = this_hour;
						data_s(entry).times = data(:,1,hr_ind);
						data_s(entry).x = data(:,8,hr_ind);
						data_s(entry).y = data(:,9,hr_ind);
						data_s(entry).z = data(:,10,hr_ind);
						for f_ind = [2:length(omni_fields)] % add corresponding omni data
							omni_field = char(omni_fields(f_ind));
							data_s(entry).(omni_field) = cell2mat({ omni_data(matching).(omni_field) });
						end
						entry = entry+1;
					%else
					%	dels(i) = true;
					end
				end
			
				clear('data');
				data = data_s;%(~dels);
				
				% save the data if there is any
				if max(size(data)) > 1
					save(f_to_save,'data','data_bins');
				end
		    end
            
            
        end
    end


end
