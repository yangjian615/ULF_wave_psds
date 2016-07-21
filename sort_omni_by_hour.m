% Puts omni data into windows to match up with data
% Data is still not in structure format but old and new omni data will be (old - every minue, new - every window)
% Doesn't run around backwards like fix_moved_hours but loads in previous omni_data file. This is more expensive (each file loaded twice) but more flexible.
%
% perc_ok : what percentage/ratio of the window needs to be there before we take mean? Value should be from 0-1. Default is 100%

function [] = sort_omni_by_hour(data_dir,station,years,months,window_length,data_t_res,perc_ok)

	if isempty(perc_ok)
		perc_ok = 1;
	end
	
	win_mins = window_length/60;
	
	if mod(window_length,60^2) ~= 0 % don't want/need to run if have hour data
		for year = years
			for month = months 
				fdata_to_load = strcat(data_dir,sprintf('/sorted2/%s_%d_%d_%d',station,win_mins,year,month));
				fomni_to_load = strcat(data_dir,sprintf('/omni_1min/fixed/%s_omni_1min_%d_%d_%d',station,win_mins,year,month));
				fomni_to_save = strcat(data_dir,sprintf('/omni_1min/sorted1/%s_omni_1min_%d_%d_%d',station,win_mins,year,month));
				
				disp(sprintf('Sorting omni data into windows, %s %d %d',station, year,month));
				
				% and get previous to load
				fprev_to_load = [];
				if month == 1
					fprev_to_load = strcat(data_dir,sprintf('/omni_1min/fixed/%s_omni_1min_%d_%d_%d',station,win_mins,year-1,12));
				else 
					fprev_to_load = strcat(data_dir,sprintf('/omni_1min/fixed/%s_omni_1min_%d_%d_%d',station,win_mins,year,month-1));
				end				
				
				warning('using this system you should also load in teh previous month to cater for overlaps');
				
				load(fdata_to_load);
				window_dates = data(1,1,:);
				
				load(fomni_to_load);
				curr_omni = omni_data;
				
				% now get across stuf that should be in this month
				if exist(strcat(fprev_to_load,'.mat'))
					load(fprev_to_load);
					month_start = datenum([year month 1 0 0 0]);
					month_end = omni_data(length(omni_data)).dates;
					in_month = isbetween(datetime(datevec(cell2mat({omni_data.dates}))),datetime(datevec(month_start)),datetime(datevec(month_end)));
					keep = omni_data(in_month);
					disp(sprintf('Rescued %d data entries from wrong month',sum(in_month)));
					omni_data = [keep,curr_omni];
				end
				
				
				omni_out = [];
				omni_fields = fieldnames(omni_data);
				o_dates = cell2mat({omni_data.dates});
			
			
				bad = 0;
				good = 0;
				
				
				omni_index =0;
				for win_count = [1:length(window_dates)]
				% Go back so all data in window is for window length before the date
				% Make corresponding omni data. Don't worry if there isn't any - the CARISMA data
				% for corresponding window will be removed in remove_bad_omni.
				%
				% These are done separately to preserve the ability to use low=res omni.
				%
				% Lagging of window easily added here
					this_time = window_dates(win_count);
					
					% calculate where beginning of window is
					time_temp = datevec(this_time);
					time_temp(6) = time_temp(6) - window_length; % recall should be in seconds!
					win_begin = datenum(time_temp);
					
					% Do we want this interval closed at both ends or just one - do we include both times?
					% Include only teh beginning of window, exclulde the end. Else you need to expect another data point
					win_end = datevec(this_time);
					win_end(6) = win_end(6) -1;
					win_end = datenum(win_end);
					
					
					in_win = isbetween(datetime(datevec(o_dates)),datetime(datevec(win_begin)),datetime(datevec(win_end)));
					%in_win = o_dates >= win_begin & o_dates < this_time; 
					warning('Should it be <= or < ??');
					
					%disp(sum(in_win)); % how many OK in this window?
					

					
					% add means of the OMNI data top structure if we have enough data points
					if sum(in_win) >= floor(perc_ok*window_length/60)
						good = good+1;
						omni_index = omni_index+1; %so we know where to add info
						for o_count = [1:length(omni_fields)]
							if o_count == 1 
								omni_out(omni_index).dates = datenum(time_temp);
							else
								o_field = char(omni_fields(o_count));
								avg_odata = mean( cell2mat({omni_data(in_win).(o_field)}) );
								omni_out(omni_index).(o_field) = avg_odata;
							end
						end
						
					else
						bad = bad+1;
						%disp(datetime(datevec(this_time)));
						%disp(sprintf('has %d points, should have %d',sum(in_win),window_length/60));
					end
					disp(sum(in_win) / (window_length/60)); %ratio of window we had here
					
					
				end
				
				
				disp(good);
				disp(bad);
				
				clear('omni_data');
				omni_data = omni_out;
				save(fomni_to_save,'omni_data');
				
				
			end
		end
	end
	
end