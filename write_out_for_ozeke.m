% Puts it in his text file format 
% station
% data_dir: where load data
% loc_dir: where save data

% He seems to want a text file for each day (!) so you will just have to loop around EVERYTHING.
% Each file should contain all stations.

% I haven't bothered to make this remotely efficient as it will take forever anyway.
% IMPORTANT NOTE: Units are in mHz and (nT)^2 / mHz


function [] = write_out_for_ozeke( data_dir, loc_dir,years)
	
	ptag = get_ptag();
	do_print(ptag,2,'write_out_for_ozeke:starting \n');
	
	
	gopts = make_basic_struct('get_opts');
	
	add_extras = make_basic_struct('add_omni_extras');
	%add_extras.L = true;
	%add_extras.MLT_val = true;
	
	% get the data including annual MLT and L values for each station
	% Use a struct where fields are stations
	
	stations = {'GILL','FCHU','ISLL','PINA'};
	
	%years = [1990:2005];
	months = [1:12];
	days = [1:31];

	
	for year = years
		
		data = [];
		all_station_data = [];
		
		for s_count = 1:length(stations)
			station = stations{s_count};
			gopts.station = station;
			gopts.y = year;
			gopts.m = months;
			
			data(1).(station) = get_all_psd_data(data_dir,gopts,add_extras);
			
			if length( data(1).(station) ) == 0
				error('write_out_for_ozeke:NoData','no data found');
			end
			
			% get all the dates and turn them into datetimes so we can use isbetween
			making_dt = datetime(datevec(cell2mat({data.(station).dates})));
			making_dt = num2cell(making_dt);
			[data.(station).dates_dt] = making_dt{:};
			
			% and a station_data one
			load(strcat(data_dir,sprintf('%s_data_struct',station))); 
			all_station_data.(station) = station_data;
			
		end
		
		
		freqs = 1e3*data.GILL(1).freqs;
		flims = [0.1,15];
		
		use_freqs = freqs >= flims(1) & freqs <= flims(2);
		
		% formatting for outoputting PSD stuff	
		freqs_format_header = repmat(' %-18.15f',1,sum(use_freqs));
		freqs_format = repmat(' %-13.12e',1,sum(use_freqs));
		freqs_format_nans = repmat(' %-18s',1,sum(use_freqs));
		
		formatSpec = strcat('%s %-1.2f %-s %-s %-02.2f\t ',freqs_format,'\n' ); %station name, L shell, H or D, hr interval, MLT of window centre, then lots of PSDs!		
		formatSpecNans = strcat('%s %-1.2f %-s %-s %-02.2f\t ',freqs_format_nans,'\n' );
		formatSpecHeader = strcat('%s %-1.2f %-s %-s %-02.2f\t ',freqs_format_header,'\n' );
		start_cell = [{'xxxx',0.00,'x','00-00',0}, freqs(use_freqs)'];

		
		
		% run around, get data,put in if exists
		%for year = years
		for month = months
			do_print(ptag,2,sprintf('write_out_for_ozeke: doing year %d, month %d \n',year,month));
			for day = days
				do_print(ptag,3,sprintf('write_out_for_ozeke: doing day %d \n',day));
				% make the file
				fname = strcat(loc_dir,sprintf('%d%02d%02d_for_conversion.dat',year,month,day));
				%disp(fname);
				fileID = fopen(fname,'w');
				fprintf(fileID,formatSpecHeader,start_cell{:});
				
				
				any_data = false; % throw away this file if empty
				for s_count = 1:length(stations)
					station = stations{s_count};
					for hr = 0:23 % even do every bloody hour
						hr_str = sprintf('%02d-%02d',hr,mod(hr+1,24)); %get 01-02 format for hours
						
						do_print(ptag,4,sprintf('write_out_for_ozeke: doing hr %d \n',hr));
						
						thishr_l = datetime([year month day hr -5 0]);
						thishr_u = datetime([year month day hr 5 0]);

						this_data = isbetween([data.(station).dates_dt], thishr_l, thishr_u);

						% get MLT and L, which we will need even for empty stuff
						this_station_year = cell2mat({all_station_data.(station).year}) == year;
						this_mlt_midnight = all_station_data.(station)(this_station_year).MLT;
						this_mlt = (hr+0.5) - this_mlt_midnight; % he wants MLT of middle of each hour
						this_L = all_station_data.(station)(this_station_year).L;
						
						% make sure the MLT is positive
						if this_mlt < 0
							this_mlt = this_mlt + 24;
						end
						
						for c_count = 1:2
						
							if c_count == 1	
								coord = 'x'; g_coord = 'H';
							else 
								coord = 'y'; g_coord = 'D';
							end
							do_print(ptag,4,sprintf('write_out_for_ozeke: doing coord %s \n',coord));
							
							cell_to_write = {};
							cell_to_write_start = {station,this_L,g_coord,hr_str,this_mlt};
							
							if sum(this_data) == 0 
								% row of NaNs
								cell_to_write = [cell_to_write_start num2cell(nan(1,sum(use_freqs)))];
								fprintf(fileID,formatSpecNans,cell_to_write{:});
								
								
							elseif sum(this_data) == 1
								% put hte data in
								any_data = true;
								
								cell_to_write = [cell_to_write_start num2cell( 1e-3*data.(station)(this_data).(sprintf('%sps',coord))(use_freqs))']; %factor of 1e-3 to convert units
								fprintf(fileID,formatSpec,cell_to_write{:});
								
						
							else
								error('write_out_for_ozeke:TooMuchForHour',' too many data entries fro same hour');
							end
						end
				
	
					end
				end
				
				fclose(fileID);
				
				if ~any_data
					do_print(ptag,2,sprintf('write_out_for_ozeke: no data for day so removing file %s \n',fname));
					delete(fname);
				end
				
			end
		end
		%end
	
	end
	
	do_print(ptag,2,'write_out_for_ozeke: done all requested years \n')
	
end
	
	
	
	
	
	
	