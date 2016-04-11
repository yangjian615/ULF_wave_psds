
% Load in all the previously calculated PSDs and find medians for each SW
% speed bin and day sector. SW speeds are binned here.
% Note that if there are no results to plot median PSDs with then we return
% a value value for that slice of the matrix.

% You can specify whether you want to plot the psd ('psd') or the power spectrum ('ps').

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


function [output,bin_limits,output_info,hrs_out,dys_out,val_out] = get_psd_medians( data_dir, station, years, months, sort_by, ps_or_psd)

    %recall omni data is datenum,SW speed bin, flow pressure, proton density
	
	%initialise stuff
	meds = [];
	output = [];
	bin_limits = [];
    hrs_out = [];
    dys_out = [];
    val_out = []; % corresponding values out, speed bin or whatever

	p_f = ps_or_psd;
    
	[all_data,data_bins] = get_all_psd_data(data_dir,station,years,months);
	
    
	% sort according to options
	if strcmp(sort_by,'no_sort') %just find medians of all of them 
        disp('Not sorting by MLT or solar wind speed');
        meds(:,1) = median(cell2mat({all_data.(sprintf('x%s',p_f))}),2);
        meds(:,2) = median(cell2mat({all_data.(sprintf('y%s',p_f))}),2);
        meds(:,3) = median(cell2mat({all_data.(sprintf('z%s',p_f))}),2);
        data_size = max(size(all_data));
        output_info = data_size;
        [y m d h] = datevec(cell2mat({all_data.dates}));
        hrs_out = h;
        days = [ y' m' d' zeros(size(y')) zeros(size(y')) zeros(size(y')) ];
        dys_out = datenum(days);
	else
		%data_bins
		num_quants = length(cell2mat(data_bins.(sort_by)))+1;	
		
		for bin = [1:num_quants]
			in_this_bin = cell2mat({all_data.speed_bin}) == bin;


			for sector = [1:4]
				in_this_sector = cell2mat({all_data.MLT}) == sector;
				this_sector_this_bin = in_this_sector & in_this_bin;
				if sum(this_sector_this_bin) > 0 %ie if any results found
					meds(:,1,sector,bin) = median(cell2mat({all_data(this_sector_this_bin).(sprintf('x%s',p_f))}),2);
					meds(:,2,sector,bin) = median(cell2mat({all_data(this_sector_this_bin).(sprintf('y%s',p_f))}),2);
					meds(:,3,sector,bin) = median(cell2mat({all_data(this_sector_this_bin).(sprintf('z%s',p_f))}),2);
					output_info(sector,bin) = sum(in_this_sector); %how many results DID we find?
				end

			end
		end
		
		
		% put info on this to go out
		hour_dates = cell2mat({all_data.dates});
		[y m d h mins secs] = datevec(hour_dates);
		hrs_out = h;
		dys_out = datenum([y' m' d' zeros(size(y')) zeros(size(y')) zeros(size(y'))]);
		val_out = cell2mat({all_data.(sprintf('%s_bin',sort_by))});
		
		  
		bin_limits = cell2mat(data_bins.(sort_by));
    end
        
    output = meds;
            
    

end
