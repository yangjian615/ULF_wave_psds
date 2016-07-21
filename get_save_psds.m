
% Does the calculations for each month, then saves the PSD and omni data
% away. Does not return the frequency axis.

function [] = get_save_psds( data_dir, station, years, months, window_length )

    disp('Finding the power spectrum and PSDs');
	win_mins = window_length/60;
	
    for year = years
        for month = months
            f_to_load = strcat(data_dir,sprintf('ready/%s_%d_%d_%d',station,win_mins,year,month));
            f_to_save = strcat(data_dir, sprintf('psds/%s_%d_%d_%d',station,win_mins,year,month));
			
			
            if exist(strcat(f_to_load,'.mat')) ~= 2 
				warning(sprintf('>>> Could not load file <<< %s',f_to_load));
			else
				load(f_to_load);
				disp(sprintf('calculating psds for %s, year %f month %f',station,year,month));
				
				% get f_res for the psds
				N = length( cell2mat({data(1).x}) );
				time_temp = data(1).times;
				time1 = time_temp(1);
				time2 = time_temp(2);
				t_res = abs(etime(datevec(time1),datevec(time2))); % in seconds
				f_res = 1/(N*t_res);
				
				freqs = [];
			
				s_size = size(data);
				for entry = [1:s_size(2)]
					to_calc = [data(entry).x data(entry).y data(entry).z];
					[pxx,freqs] = calculate_multitaper_powerspectrum(to_calc,t_res);
					data(entry).xps = pxx(:,1);
					data(entry).yps = pxx(:,2);
					data(entry).zps = pxx(:,3);
					data(entry).freqs = freqs;
				end
  
				save(f_to_save,'data','data_bins');
            end
			
            
        end
    end

end