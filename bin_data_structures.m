% Bin all the omni data fields, add info to data structures

function [] = bin_data_structures( data_dir, station, years, months, day_ranges )
	
	num_quants =6; %blah
	
	% get bin limits first
	f_to_load = strcat(data_dir,sprintf('%s_omni',station));
	load(f_to_load);	
	omni_fields = fieldnames(omni_data);
	omni_fields = omni_fields(2:length(omni_fields));
	omni_bins = struct();
	for f_ind = [1:length(omni_fields)] %don't need to include dates fields
		fn = char(omni_fields(f_ind));
		bin_limits = num2cell(get_omni_quantiles( data_dir,station,num_quants,fn));
		omni_bins.(fn) = bin_limits;
	end
	

	for year = years
		for month = months 
			
            f_to_load = strcat(data_dir,sprintf('structured/%s_%d_%d',station,year,month));
            f_to_save = strcat(data_dir, sprintf('ready/%s_%d_%d',station,year,month));
			
            if exist(strcat(f_to_load,'.mat')) ~= 2 
				warning(sprintf('>>> Could not load file <<< %s',f_to_load));
			else
				disp(sprintf('Binning the OMNI data from %s, year %d month %d to structure form',station,year,month));
				load(f_to_load);
				
				% bin the OMNI data
				omni_fields = fieldnames(omni_bins);
				for i = [1:length(omni_fields)]
					o_field = char(omni_fields(i));
					data_to_bin = cell2mat({data.(o_field)});
					%bin_limits = get_omni_quantiles( data_dir,station,num_quants,o_field);
					bin_limits = cell2mat(omni_bins.(o_field));
					binned = num2cell(bin_data(data_to_bin,bin_limits));
	
					% now pu tin structures
					[data.(sprintf('%s_bin',o_field))] = binned{:};
				end
				
				% bin by MLT
				[y d m h mins secs] = datevec(cell2mat({data.dates}));
				in_each_sector = sort_by_sectors(h,day_ranges);
				for sector = [1:max(size(day_ranges))]
					sectors_to_save = num2cell(sector*ones(1,sum(in_each_sector(:,sector))));
					[data(in_each_sector(:,sector)).MLT] = sectors_to_save{:};
				end	
				data_bins = omni_bins; % do you really need to save this in every file??? 
				% NEXT: check this makes it's way through and can be used in plotting and psds , get medians etc
				
				save(f_to_save,'data','data_bins');
			end


		end

	end


end