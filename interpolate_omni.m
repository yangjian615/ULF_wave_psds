% Interpolation of gaps in omni data, using same code as for CANOPUS data


function [] = interpolate_omni( data_dir, station, years, months, window_length )

	data_folder = strcat(data_dir,'omni_1min/');
	win_mins = window_length/60;
	for year = years	
		for month = months
		
			f_to_open = strcat(data_folder,sprintf('prepped/%s_omni_1min_%d_%d_%d',station,win_mins,year,month));
			load(f_to_open);
			
			f_to_save = strcat(data_folder,sprintf('fixed/%s_omni_1min_%d_%d_%d',station,win_mins,year,month));
			
			o_fields = fieldnames(omni_data);
			o_length = length(omni_data);
	
			
			% for all omni dates, round down to seconds (or to closest? this would be o_dates(6) = 60*round(first_date(6)/60);
			o_dates = datevec(cell2mat({omni_data.dates}));
			o_dates(:,6) = 0;
			%add them back in to structure, stupid method.
			o_datenums = num2cell(datenum(o_dates));
			[omni_data(:).dates] = o_datenums{:};%deal(datenum(o_dates));
			
			
			% transfer all omni data into matrix for fixing
			o_mat = nan(o_length,length(o_fields));
			for of_count = [1:length(o_fields)]
				o_mat(:,of_count) = cell2mat({omni_data.(o_fields{of_count})});
			end
			
			% make matrix with gaps for missing data
			to_fix = make_gappy_matrix_by_date( o_mat, 60 );
			
			% if false % old
				% % be awkwards, tranfer all back into a single matrix for fixing
				% % we need a minute between each obsevercation, so make this.
				% first_date = datevec(omni_data(1).dates); 
				% first_date(6) = 0; % round seconds down (or to closest? this would be first_date(6) = 60*round(first_date(6)/60);
				
				% last_date = datevec(omni_data(o_length).dates);
				% last_date(6) = 0;
				
				% max_length = ceil(etime(first_date,last_date)/60);
				
				% % make the list of all dates including missing ones - add in minutes then convert
				% basis = ones(max_length,1);
				% dates_mat = [first_date(1)*basis first_date(2)*basis first_date(3)*basis first_date(4)*basis first_date(5)*basis 0*basis];
				% dates = datenum(dates_mat); dates_mat = datevec(dates); dates = datenum(dates_mat);
				
				% to_fix = nan(max_length+o_length,length(o_fields)); % date is one of these! 
				
				% % sort out zero for seconds in omni_data
				% o_dates = datevec(cell2mat({omni_data.dates}));
				% o_dates(:,6) = 0;
				% [omni_data(:).dates] = deal(datenum(o_dates));
				
				% % stick all together then sort and keep unique dates (same as in do_thresholding)
				% to_fix = nan(max_length+o_length,length(o_fields)); 
				% to_fix(1:length(omni_data),1) = datenum(o_dates);
				% to_fix(length(omni_data)+1:max_length+o_length,1) = dates;
				
				% % fill in data from other omni fields too
				% for of_count = [2:length(o_fields)]
					% to_fix(1:o_length,of_count) = cell2mat({omni_data.(o_fields{of_count})});
				% end
				
				% % sort into order and keep one of each date
				% to_fix = sortrows(to_fix,1);  
				% [unique_dates,unique_date_indices] = unique(to_fix(:,1));
				% to_fix = to_fix(unique_date_indices,:);
			% end
			
			
			warning('Dodgy method for choosing size of gaps to fill!!');
			disp('Currently fixing up to 8mins out of each hour for each col. of omni data used');
			data = interpolate_fix( to_fix, [2:length(o_fields)], window_length/60 , (o_length-1)*ceil((8/60)*(window_length/60)) ); %window_length/60 should be no. of mins in chunk
			disp(size(data,1));		

			% now read back into sturcture
			omni_data = [];
			for of_count =  [1:length(o_fields)]
				this_data = num2cell(data(:,of_count));
				[omni_data(1:size(data,1)).(o_fields{of_count})] = deal(this_data{:});%deal(data(:,of_count));
			end
			
			save(f_to_save,'omni_data');
			
			
			
		end
	end
		




end
	