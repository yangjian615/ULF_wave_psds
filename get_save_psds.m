
% Does the calculations for each month, then saves the PSD and omni data
% away. Does not return the frequency axis.

function [] = get_save_psds( data_dir, station, years, months )

    disp('Finding the power spectrum and PSDs');
	
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
					data(entry).xps = calculate_multitaper_powerspectrum(data(entry).x,t_res);
					data(entry).yps = calculate_multitaper_powerspectrum(data(entry).y,t_res);
					[data(entry).zps,data(entry).freqs] = calculate_multitaper_powerspectrum(data(entry).z,t_res);
					%data(entry).xps = calculate_powerspectrum(data(entry).x);
					%data(entry).yps = calculate_powerspectrum(data(entry).y);
					%data(entry).zps = calculate_powerspectrum(data(entry).z);
					%data(entry).xpsds = (1/f_res)*data(entry).xps;
					%data(entry).ypsds = (1/f_res)*data(entry).yps;
					%data(entry).zpsds = (1/f_res)*data(entry).zps;
				end
				%data.freqs = freqs;
  
				save(f_to_save,'data','data_bins');
            end
			
            
        end
    end

end