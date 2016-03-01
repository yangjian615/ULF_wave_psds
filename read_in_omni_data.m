% This reads in the OMNI data and keeps the columns of year, day, hour,
% bulk flow speed and Kp value.
% DATE      SW SPEED        Kp VALUE        E-AMPLITUDE
% DATE      SW SPEED        Kp VALUE        E-AMPLITUDE
% DATE      SW SPEED        Kp VALUE        E-AMPLITUDE
% DATE      SW SPEED        Kp VALUE        E-AMPLITUDE
% DATE      SW SPEED        Kp VALUE        E-AMPLITUDE

% This should also convert to magnetic local time and round down the hour.
% History:
% 16-01-26 Changes for test data: read in different data for TEST station
% 16-01-27 Changes for test data: add in conversion for dates. Move dates = [y 0 d 0 0 0] to after this.
% 16-02-01 Fix dates mistakes for test data. And possibly for a ll data?

function output = read_in_omni_data( data_dir, station, years )

    save_removed = false; %save data thrown out for being bad
    do_mlt_conversion = true; %SHOULD ALMOST ALWAYS BE TRUE

    function output = convert_Kp( input );
        % Converts Kp values to 9-point system from OMNI format 0,3,7,10,13,17...
        output = zeros(size(input));

        output( input < 10 ) = 0;
        output( input >= 10 & input < 20 ) = 1;
        output( input >= 20 & input < 30 ) = 2;
        output( input >= 30 & input < 40 ) = 3;
        output( input >= 40 & input < 50 ) = 4;
        output( input >= 50 & input < 60 ) = 5;
        output( input >= 60 & input < 70 ) = 6;
        output( input >= 70 & input < 80 ) = 7;
        output( input >= 80 & input < 90 ) = 8;
        output( input >= 90 ) = 9;


    end    

    data_folder = data_dir;
    f_to_open = strcat(data_folder,'omni2_all_years.dat'); 
	if strcmp(station,'TEST')
		f_to_open = strcat(data_folder,'TEST_omni_all.txt');
	end	
    f_to_save = strcat(data_folder,sprintf('%s_omni',station));
    f_to_save2 = strcat(data_folder,sprintf('removed_%s_omni',station));
    temp_data = dlmread(f_to_open);
    
    
    output = zeros(max(size(temp_data)),4);
    y = temp_data(:,1);
    d = temp_data(:,2);
    h = temp_data(:,3);
    dates = [y ones(size(y)) d h zeros(size(y)) zeros(size(y)) ]; 
	
	%convert to correct format, necessary for TEST data
	if true %strcmp(station,'TEST') I THINK YOU FOUND YOUR BUG
		dates = datevec(datenum(dates));
		y = dates(:,1);
        m = dates(:,2);
		d = dates(:,3);
        h = dates(:,4);
		dates = [y m d h zeros(size(y)) zeros(size(y)) ];
	end
		
	
    our_years = y >= 1990 & y <= 2004;
	
	if length(our_years) ~= length(temp_data)
		error('>>> Stuff is wrong size<<<');
	end
    
    dates = dates(our_years,:);
    temp_data = temp_data(our_years,:);
    output = zeros(sum(our_years),4);
    
    % fill i the data part
    output(:,2) = temp_data(:,25); %the SW speed
    output(:,3) = temp_data(:,29); % the flow pressure
    output(:,4) = temp_data(:,24); % the proton density
    
    
    mlts = read_in_mlt_midnight( data_dir, station );
    
	% sort out bad data
    bad_data = output(:,2) >= 9998; 
	bad_data = bad_data | output(:,3) >= 99;
	bad_data = bad_data | output(:,3) == 0; %CHECK THIS WITH MATT
	bad_data = bad_data | output(:,4) >= 999;
	bad_data = bad_data | output(:,4) == 0; %CHECK THIS WITH MATT
    if save_removed %check what we've thrown out
        removed_dates = dates(bad_data,:);
        removed = output(bad_data,:);
    end
    dates(bad_data,:) = [];
    output(bad_data,:) = [];
    
    % do convrsion and sort out datenums for output
    for year = years
        this_year = dates(:,1) == year;
        if do_mlt_conversion
            dates(this_year,4) = dates(this_year,4) - mlts( mlts(:,1)== year, 2 );
        end
        dates(:,4) = floor(dates(:,4));
        
        if save_removed % have to do this here too!
            this_year = removed_dates(:,1) == year;
            removed_dates(this_year,4) = removed_dates(this_year,4) - mlts( mlts(:,1) == year,2);
            removed_dates(:,4) = floor(removed_dates(:,4));
        end
    end
    
    output(:,1) = datenum( dates );
    
    %output(:,3) = convert_Kp( output(:,3) );
    
    omni_data = output;
    save( f_to_save, 'omni_data' ) ;
    
    if save_removed
        removed(:,1) = datenum(removed_dates);
        save(f_to_save2,'removed');
    end
    

end