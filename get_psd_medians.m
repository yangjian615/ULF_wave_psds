
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


function [output, output_info,hrs_out,dys_out,spd_out] = get_psd_medians( data_dir, station, years, months, day_ranges )

    %recall omni data is datenum,SW speed bin, Kp, electric field
    sort_them = true;
    meds = zeros(360,3,4,6); %freq, xyz, sector, bin
    output_info = zeros(4,6);
    hrs_out = [];
    dys_out = [];
    spd_out = [];
    
    if sum(sum(day_ranges)) == 0
        sort_them = false;
        meds = zeros(360,3);
        output_info = 0;
    end
    
    speeds = [1:6];
    day_sectors = [1:4];
    
    unsorted_psds = zeros(360,3,0);
    unsorted_omni = zeros(4,0);
   
    % Load in ALL the data into huge thing
    for year = years
        for month = months
            load(strcat(data_dir,sprintf('psds/%s_%d_%d.mat',station,year,month)));
            disp(sprintf('Loading PSD data for %s, year %d month %d',station, year, month)); 
            %now have hr_psds and mini_omni
        
            
            unsorted_psds = cat(3,unsorted_psds,hr_psds);
            unsorted_omni = cat(2, unsorted_omni, mini_omni');
            
        end
    end
    
    omni_size = size(unsorted_omni);
    psds_size = size(unsorted_psds);
    
    % check these are correct
    if omni_size(2) ~= psds_size(3)
        error('Lengths of psds, omni do not match');
    end
    
    if sort_them
        % bin the SW speeds
        unsorted_omni(2,:) = bin_sw_speed( unsorted_omni(2,:) );


        % now sort and find medians. Start off without removing checked data
        for speed = speeds
            at_this_speed = unsorted_omni(2,:) == speed;
            this_speed_psds = unsorted_psds(:,:,at_this_speed);
            this_speed_omni = unsorted_omni(:, at_this_speed);
            [y m d this_speed_hours] = datevec( this_speed_omni(1,:) );

            % put info on this to go out
            if min(size(this_speed_hours))>0
                hrs_out = cat(1,hrs_out,this_speed_hours');
                dys_out = cat(1,dys_out,datenum([y' m' d' zeros(size(y')) zeros(size(y')) zeros(size(y'))]));
                spd_out = cat(1,spd_out,speed*ones(size(y')));
            end
            
            for sector = day_sectors
                %disp(sprintf('Sector %f and speed %f',sector,speed));
                hr_range = day_ranges(sector,1:2);

                if hr_range(2) > hr_range(1)
                    in_this_sector = (this_speed_hours >= hr_range(1)) & (this_speed_hours < hr_range(2));
                else
                    in_this_sector = ( (this_speed_hours >= hr_range(1)) & (this_speed_hours < 24) )  | ( (this_speed_hours >= 0) & (this_speed_hours < hr_range(2)) );
                end

                if sum(in_this_sector) > 0 %ie if any results found
                    sorted_psds = this_speed_psds(:,:,in_this_sector);
                    meds(:,:,sector,speed) = median(sorted_psds,3);
                    output_info(sector,speed) = sum(in_this_sector); %how many results DID we find?
                end


            end
        end
    else %just find medians of all of them 
        meds(:,:) = median(unsorted_psds,3);
        data_size = size(unsorted_psds);
        output_info = data_size(3);
    end
        
            
    output = meds;
            
    

end
