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
    
    dates = dates(our_years,:);
    temp_data = temp_data(our_years,:);
    output = zeros(sum(our_years),4);
    
    %output(:,1) = datenum([y ones(size(y)) d h zeros(size(y)) zeros(size(y)) ]);
    output(:,2) = temp_data(:,25); %the SW speed
    output(:,3) = temp_data(:,39); % the Kp value, although not mapped properly over yet.
    output(:,4) = temp_data(:,36); % the electric field mV/m, -V(km/s) * Bz (nT; GSM) * 10**-3 
    
    % Bz(GSM) is towards magnetic north on mapped plane.
    
    mlts = read_in_mlt_midnight( data_dir, station );
    
    bad_data = output(:,2) == 9999 | output(:,3) == 9999 | output(:,4) == 9999;
    dates(bad_data,:) = [];
    output(bad_data,:) = [];
    
    for year = years
        this_year = dates(:,1) == year;
        mlts( mlts(:,1)== year, 2 );
        dates(:,4) = dates(:,4) - mlts( mlts(:,1)== year, 2 );
        dates(:,4) = floor(dates(:,4));
    end
    
    output(:,1) = datenum( dates );
    
    output(:,3) = convert_Kp( output(:,3) );
    
    omni_data = output;
    save( f_to_save, 'omni_data' ) ;
    

end