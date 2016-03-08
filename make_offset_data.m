% Shifts slices across by a half if they are next in time. Also shifts the omni data


function [] = make_offset_data( data_dir, station, years, months )

	
    load(strcat(data_dir,sprintf('%s_omni',station)));
    omni_all = omni_data; %manyx4: DATENUM      SW SPEED    Flow pressure    proton density    Note the datenum should be for the very beginning of that hour.
    omni_size = size(omni_data);

    for year = years
        for month = months
            f_to_load = strcat(data_dir,sprintf('/ready/%s_%d_%d',station,year,month));
            f_to_save = strcat(data_dir,sprintf('/ready/offset/%s_%d_%d',station,year,month));
			
			if exist(strcat(f_to_load,'.mat')) == 2
				disp(sprintf('Making offset data for %s, year %d month %d',station,year,month));
				load(f_to_load);
				
				
				data_size = size(data);
				% do_shift = false(data_size(3),1);
				
				% for i = [2:data_size(3)]
					% prev_time = datevec(data(data_size(1),1,i-1));
					% this_time = data(1,1,i);
					
					% prev_time(6) = prev_time(6) +5;
					% do_shift(i) = datenum(prev_time) == this_time;
				% end		
				
				to_reshape = data;
				to_reshape = permute(to_reshape,[1 3 2]); %gotta do it before reshaping, dunno why 
				reshaping = reshape(to_reshape,[],10);
				
				%now shift by half an hour
				reshaping(:,6) = reshaping(:,6) - 0.5;
				reshaping(:,1) = datenum(reshaping(:,2:7));
				reshaping(:,2:7) = datevec(reshaping(:,1));
				
				% lose the ones at the edges (cba with between months, too)
				cut_off_index = 1;
				while reshaping(cut_off_index,7) ~= 0
					cut_off_index = cut_off_index+1;
				end
				reshaping = reshaping( cut_off_index: length(reshaping)-(720-cut_off_index+1),:);	
				reshaping = reshape( reshaping,720,[],10 );
				offset_data = permute( reshaping,[1 3 2]);
				data_size = size(offset_data);
				
				
				% now throw any out that have wrong hour.
				whole_hours = false(1,data_size(3));
				for hour = [1:length(whole_hours)]
					whole_hours(hour) = sum( offset_data(:,5,hour) ~= offset_data(1,5,hour) ) == 0;
				end
				offset_data = offset_data(:,:,whole_hours);
				
				if min(size(offset_data)) > 0
					% now reshape AGAIN to give back their proper times
					offset_data = permute(offset_data,[1 3 2]);
					offset_data = reshape(offset_data,[],10);
					offset_data(:,6) = offset_data(:,6) +0.5;
					offset_data(:,1) = datenum(offset_data(:,2:7));
					offset_data(:,2:7) = datevec(offset_data(:,1));
					offset_data = reshape(offset_data,720,[],10);
					offset_data = permute(offset_data,[1 3 2]);
					
					data = offset_data;
					data_size = size(data);
					
					% and the OMNI data?
					offset_mini_omni = zeros(data_size(3),4);
					all_hours = offset_data(:,2:7,:);
					all_hours(:,5:6,:) = 0;
					earlier_hr = datenum([squeeze(all_hours(1,1:6,:))']);
					later_hr = datenum([squeeze(all_hours(720,1:6,:))']);
					dels = false(1,data_size(3));
					for hour = [1:data_size(3)]
						earlier_omni = mini_omni(:,1) == earlier_hr(hour);
						later_omni = mini_omni(:,1) == later_hr(hour);
						if sum(earlier_omni) ~=1 | later_omni ~=1
							warning('>> Cant get OMNI data to offset. Why?? <<<');
							dels(hour) = true;
						else 
							offset_mini_omni(hour,:) = ( mini_omni(earlier_omni,:) + mini_omni(later_omni,:) )/2;
						end
					end
					if sum(dels) > 0
						data(:,:,dels) = [];
						offset_mini_omni(dels,:) = [];
					end
					mini_omni = offset_mini_omni;
					
					save(f_to_save,'data','mini_omni');
				else
					warning('>>> Could not get offset data for this month<<<');
				end
			end
		end
	end			

end