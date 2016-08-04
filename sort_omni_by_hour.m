% Puts omni data into windows to match up with data
% Data is still not in structure format but old and new omni data will be (old - every minue, new - every window)
% Doesn't run around backwards like fix_moved_hours but loads in previous omni_data file. This is more expensive (each file loaded twice) but more flexible.
%
% We don't just sort into hour but see whether we have OMNI data for existing windows in CANOPUS data.
% 
% perc_ok : what percentage/ratio of the window needs to be there before we take mean? Value should be from 0-1. Default is 100%

function [] = sort_omni_by_hour(data_dir,data_opts,data_t_res,perc_ok)

	ptag = get_ptag();
	
	do_print(ptag,2,'sort_omni_by_hour: entering function\n');

	station = data_opts.station;
	years = data_opts.y;
	months = data_opts.m;
	win_mins = data_opts.win_mins;
	
	
	if isempty(perc_ok)
		perc_ok = 1;
	end

	
	if mod(win_mins,60) ~= 0 % don't want/need to run if have hour data
		for year = years
			for month = months 
				fdata_to_load = strcat(data_dir,sprintf('/sorted2/%s_%d_%d_%d',station,win_mins,year,month));
				fomni_to_load = strcat(data_dir,sprintf('/omni_1min/fixed/%s_omni_1min_%d_%d_%d',station,win_mins,year,month));
				fomni_to_save = strcat(data_dir,sprintf('/omni_1min/sorted1/%s_omni_1min_%d_%d_%d',station,win_mins,year,month));
				
				do_print(ptag,2,sprintf('sort_omni_by_hour: Sorting omni data into windows, %s %d %d\n',station, year,month));
				
				if exist(strcat(fdata_to_load,'.mat'),'file') & exist(strcat(fomni_to_load,'.mat'),'file')

					% and get previous to load
					fprev_to_load = [];
					if month == 1
						fprev_to_load = strcat(data_dir,sprintf('/omni_1min/fixed/%s_omni_1min_%d_%d_%d',station,win_mins,year-1,12));
					else 
						fprev_to_load = strcat(data_dir,sprintf('/omni_1min/fixed/%s_omni_1min_%d_%d_%d',station,win_mins,year,month-1));
					end				
					
					load(fdata_to_load);
					window_dates = data(1,1,:);
					
					load(fomni_to_load);
					curr_omni = omni_data;
					
					% now get across stuf that should be in this month
					if exist(strcat(fprev_to_load,'.mat'),'file')
						load(fprev_to_load);
						prev_dates = datevec(cell2mat({omni_data.dates}));
						in_month = prev_dates(:,2) == month;
						keep = omni_data(in_month);
						do_print(ptag,3,sprintf('Rescued %d data entries from wrong month\n',sum(in_month)));
						omni_data = [keep,curr_omni];
					end
					
					window_edges = nan(size(data,3),2);
					window_edges(:,1) = data(1,1,:);
					window_edges(:,2) = data(end,1,:);
					
					
					omni_out = [];
					omni_fields = fieldnames(omni_data);
					o_dates = cell2mat({omni_data.dates});
				
				
					bad = 0;
					good = 0;
					
					
					omni_index =0;
					for win_count = [1:size(data,3)]
					% Go back so all data in window is for window length before the date
					% Make corresponding omni data. Don't worry if there isn't any - the CARISMA data
					% for corresponding window will be removed in remove_bad_omni.
					%
					% These are done separately to preserve the ability to use low=res omni.
					%
					% Lagging of window easily added here
						win_begin = window_edges(win_count,1);
						win_end = window_edges(win_count,2);
						
	
						in_win = isbetween(datetime(datevec(o_dates)),datetime(datevec(win_begin)),datetime(datevec(win_end)));

						
						% add means of the OMNI data top structure if we have enough data points
						if sum(in_win) >= floor(perc_ok*win_mins)
							good = good+1;
							omni_index = omni_index+1; %so we know where to add info
							for o_count = [1:length(omni_fields)]
								if o_count == 1 
									omni_out(omni_index).dates = win_begin;
								else
									o_field = char(omni_fields(o_count));
									avg_odata = mean( cell2mat({omni_data(in_win).(o_field)}) );
									omni_out(omni_index).(o_field) = avg_odata;
								end
							end
							
						else
							bad = bad+1;
						end
						do_print(ptag,4,sprintf('ratio %f of this window we had \n',(sum(in_win) / (win_mins))));
						
						
					end
					
					
					do_print(ptag,3,sprintf('%d good and %d bad windows here\n',good,bad));
					
					clear('omni_data');
					omni_data = omni_out;
					if ~isempty(omni_data)
						save(fomni_to_save,'omni_data');
					end
				end
				
			end
		end
	end
	
end