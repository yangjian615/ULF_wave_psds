
% Does the calculations for each month, then saves the PSD and omni data
% away. Does not return the frequency axis.

function [] = get_save_psds( data_dir, station, years, months )

    
    for year = years
        for month = months
            f_to_load = strcat(data_dir,sprintf('ready/%s_%d_%d',station,year,month));
            f_to_save = strcat(data_dir, sprintf('psds/%s_%d_%d',station,year,month));
			
			%if do_offset 
			%	f_to_load = strcat(data_dir,sprintf('/ready/offset/%s_%d_%d',station,year,month));
			%	f_to_save = strcat(data_dir, sprintf('/psds/offset/%s_%d_%d',station,year,month));
			%end
			
            if exist(strcat(f_to_load,'.mat')) ~= 2 
				warning(sprintf('>>> Could not load file <<< %s',f_to_load));
			else
				load(f_to_load);
				disp(sprintf('calculating psds for %s, year %f month %f',station,year,month));
				
				s_size = size(data);
				for entry = [1:s_size(2)]
					data(entry).xpsds = calculate_psds(data(entry).x);
					data(entry).ypsds = calculate_psds(data(entry).y);
					data(entry).zpsds = calculate_psds(data(entry).z);
				end
  
				save(f_to_save,'data','data_bins');
            end
			
            
        end
    end

end