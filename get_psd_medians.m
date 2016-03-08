
% Load in all the previously calculated PSDs and find medians for each SW
% speed bin and day sector. SW speeds are binned here.
% Note that if there are no results to plot median PSDs with then we return
% a value value for that slice of the matrix.

% HISTORY
% 15-12-08 Created
% 16-01-29 If zeros(4,2) is entered into day_ranges, just return medians unsorted
% 16-02-01 Outpus information on the amount of data used
% 16-02-02 Also outputs day,hour and SW speed used
% 16-02-02 Major bug fix on selecting PSDs to average over midnight
% 16-02-03 Save data in slightly different folder

%outputs:
% output - the medians requested
% output_info - count of data used to get median
% d,h,sp - day, hour, speed of data


function [output,bin_limits,output_info,hrs_out,dys_out,val_out] = get_psd_medians( data_dir, station, years, months, day_ranges, sort_by, use_offset )

    %recall omni data is datenum,SW speed bin, flow pressure, proton density
	
	%initialise stuff
	meds = [];
	output = [];
	bin_limits = [];
    hrs_out = [];
    dys_out = [];
    val_out = []; % corresponding values out, speed bin or whatever

    unsorted_psds = zeros(360,3,0);
    unsorted_omni = zeros(4,0);
   
    % Load in ALL the data into huge thing
	function [unsorted_psds,unsorted_omni] = get_all_data(data_dir,station,years,months,get_offset_data)
	
		unsorted_psds = zeros(360,3,0);
		unsorted_omni = zeros(4,0);
		hr_psds = [];
		mini_omni = [];
		
		for year = years
			for month = months
				f_to_load = strcat(data_dir,sprintf('psds/%s_%d_%d.mat',station,year,month));
				if get_offset_data
					f_to_load = strcat(data_dir,sprintf('psds/offset/%s_%d_%d.mat',station,year,month));
				end
				if exist(f_to_load) ~= 2 
					warning(sprintf('>>> Could not load file <<< %s',f_to_load));
				else
					load(f_to_load);
					disp(sprintf('Loading PSD data for %s, year %d month %d',station, year, month)); 
					%now have hr_psds and mini_omni
			
				
					unsorted_psds = cat(3,unsorted_psds,hr_psds);
					unsorted_omni = cat(2,unsorted_omni, mini_omni');
				end
			end
		end
	end
    
	[unsorted_psds,unsorted_omni] = get_all_data(data_dir,station,years,months,false);
	
	if use_offset % add offset data to list
		[unsorted_psds1,unsorted_omni1] = get_all_data(data_dir,station,years,months,true);
		unsorted_psds = cat(3,unsorted_psds,unsorted_psds1);
		unsorted_omni = cat(2,unsorted_omni, unsorted_omni1);
		clearvars('unsorted_psds1','unsorted_omni1');
	end
	
    omni_size = size(unsorted_omni);
    psds_size = size(unsorted_psds);
    
    % check these are correct
    if omni_size(2) ~= psds_size(3)
        error('Lengths of psds, omni do not match');
    end
    
	% sort according to options
	if strcmp(sort_by,'no_sort') %just find medians of all of them 
        disp('Not sorting by MLT or solar wind speed');
        meds(:,:) = median(unsorted_psds,3);
        data_size = size(unsorted_psds);
        output_info = data_size(3);
        [y m d h] = datevec(unsorted_omni(1,:));
        hrs_out = h;
        days = [ y' m' d' zeros(size(y')) zeros(size(y')) zeros(size(y')) ];
        dys_out = datenum(days);
	else
		num_quants = 0;
		sort_col = 0;
		bin_limits = [];
		if strcmp(sort_by,'speed') %sort by SW speed bin
			sort_col = 2;
			num_quants = 6;
			bin_limits = [300 400 500 600 700];
			bin_limits = get_omni_quantiles(data_dir,station,num_quants,sort_col);
		elseif strcmp(sort_by,'pressure')
			sort_col = 3;
			num_quants = 6;
			% CHECK: DO YOU WANT QUANTILES FROM ALL THE STATION DATA OR FROM THE DATA YOU'RE USING?
			%bin_limits = quantile(unsorted_omni(sort_col,:),[1:num_quants-1]/num_quants);
			bin_limits = get_omni_quantiles(data_dir,station,num_quants,sort_col);
			
			% or do I want to do it in terms of quantiles at all?
			%bin_limits = linspace(min(unsorted_omni(sort_col,:)),max(unsorted_omni(sort_col,:)),num_quants+2);
			%bin_limits = bin_limits(2:num_quants+1);
		else
			error('>>> Unknown sort type <<<');
		end
			
		% Put the data in these bins
		unsorted_omni(sort_col,:) = bin_data(unsorted_omni(sort_col,:),bin_limits);%bin_sw_speed( unsorted_omni(2,:) );

		% now sort and find medians. Start off without removing checked data
		for bin = [1:num_quants]
			in_this_bin = unsorted_omni(sort_col,:) == bin;
			this_bin_psds = unsorted_psds(:,:,in_this_bin);
			this_bin_omni = unsorted_omni(:, in_this_bin);
			[y m d this_bin_hours] = datevec( this_bin_omni(1,:) );

			% put info on this to go out
			if min(size(this_bin_hours))>0
				hrs_out = cat(1,hrs_out,this_bin_hours');
				dys_out = cat(1,dys_out,datenum([y' m' d' zeros(size(y')) zeros(size(y')) zeros(size(y'))]));
				val_out = cat(1,val_out,bin*ones(size(y')));
			end

			in_each_sector = sort_by_sectors(this_bin_hours,day_ranges);
			sector_sort_size = size(in_each_sector);
			for sector = [1:sector_sort_size(2)]
				in_this_sector = in_each_sector(:,sector);
				if sum(in_this_sector) > 0 %ie if any results found
					sorted_psds = this_bin_psds(:,:,in_this_sector);
					meds(:,:,sector,bin) = median(sorted_psds,3);
					output_info(sector,bin) = sum(in_this_sector); %how many results DID we find?
				end

			end
		end
		
    end
          
    
    output = meds;
            
    

end
