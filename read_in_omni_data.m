% This reads in OMNI data (from ASCII format) and puts it in a structure with
% an entry for each data time point. We use low res omni if the length is a multiple of hours, 
% high res otherwise.

% Code from saving "removed" bad data remains but probably doesn't work any more.

% To do:
% recalulate phi, theta using vx vy vz
% put in Kp? Does it make sense for these length windows?
% variability pars, eg sigma-v
% what data is bad for new omni?

function omni_data = read_in_omni_data( data_dir, station, years, window_length, data_t_res )

    save_removed = false; %save data thrown out for being bad
    do_mlt_conversion = true;%true; %SHOULD ALMOST ALWAYS BE TRUE
	
	if ~do_mlt_conversion
		warning('>>> You asre not converting to MLT<<<');
	end	

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

	
	if mod(window_length,60^2) == 0 % multiple of hours
		disp('Using low res OMNI data');
		f_to_open = strcat(data_folder,'omni2_all_years.dat'); 
		if strcmp(station,'TEST')
			f_to_open = strcat(data_folder,'TEST_omni_all.txt');
		end	
		f_to_save = strcat(data_folder,sprintf('%s_omni_%d',station,window_length/60));
		f_to_save2 = strcat(data_folder,sprintf('removed_%s_omni',station));
		temp_data = dlmread(f_to_open);
		
		
		output = zeros(max(size(temp_data)),4);
		y = temp_data(:,1);
		d = temp_data(:,2);
		h = temp_data(:,3);
		dates = [y ones(size(y)) d h zeros(size(y)) zeros(size(y)) ]; 
		
		%convert to correct format, necessary for TEST data
		dates = datevec(datenum(dates));
		y = dates(:,1);
		m = dates(:,2);
		d = dates(:,3);
		h = dates(:,4);
		dates = [y m d h zeros(size(y)) zeros(size(y)) ];
			
		
		our_years = y >= 1990 & y <= 2004;
		
		if length(our_years) ~= length(temp_data)
			error('>>> Stuff is wrong size<<<');
		end
		
		dates = dates(our_years,:);
		temp_data = temp_data(our_years,:);
		output = zeros(sum(our_years),4);
		
		% fill in the data part
		output(:,2) = temp_data(:,25); % 'speed' the SW speed ~km/sec
		output(:,3) = temp_data(:,29); % 'pressure' the flow pressure ~nPa
		output(:,4) = temp_data(:,24); % 'Np' the proton density, ~#N/cm^3
		output(:,5) = temp_data(:,32); % 'sigma_v' the variablility in speed sigma_v ~ km/sec
		output(:,6) = temp_data(:,17); % 'Bz' Bz (GSM) ~nT
		output(:,7) = temp_data(:,38); % 'Ma' Alfven mach number ~#
		output(:,8) = temp_data(:,55); % 'Mm' Magentosonic mach number ~#
		output(:,9) = temp_data(:,26); % 'phi' longitudinal angle (v off of x axis onto GSE +/-y) ~Deg
		output(:,10) = temp_data(:,27); % 'theta' latitudinal angle (v off of x axis onto GSE +/-z) ~Deg
		output(:,11) = convert_Kp( temp_data(:,39) ); % 'Kp' yeah bad stuff ~#
		output(:,12) = temp_data(:,36); % 'E_field' ~mV/m
		output(:,13) = - temp_data(:,25) .* cos(temp_data(:,26)) .* cos(temp_data(:,27)) .*temp_data(:,17) *1e-3; % 'vxBz' E-field due to vx (different to E_field!!) ~mV/m
		output(:,14) = - temp_data(:,25) .* cos(temp_data(:,26)) .* cos(temp_data(:,27)); % vx ~km /sec
		
		mlts = read_in_mlt_midnight( data_dir, station );
		
		% sort out bad data
		bad_data = output(:,2) >= 9998; 
		bad_data = bad_data | output(:,3) >= 99;
		bad_data = bad_data | output(:,3) == 0; %CHECK THIS WITH MATT
		bad_data = bad_data | output(:,4) >= 999;
		bad_data = bad_data | output(:,4) == 0; %CHECK THIS WITH MATT
		bad_data = bad_data | output(:,5) >= 999;
		bad_data = bad_data | output(:,6) >= 999;
		bad_data = bad_data | output(:,7) >= 999;
		bad_data = bad_data | output(:,8) >= 999;
		bad_data = bad_data | output(:,9) > 360;
		bad_data = bad_data | output(:,9) < 0;
		if save_removed %check what we've thrown out
			removed_dates = dates(bad_data,:);
			removed = output(bad_data,:);
		end
		dates(bad_data,:) = [];
		output(bad_data,:) = [];
		
		% do conversion and sort out datenums for output
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
		
		omni_data = struct('dates',num2cell(output(:,1)),'speed',num2cell(output(:,2)),...
			'pressure',num2cell(output(:,3)),'Np',num2cell(output(:,4)),'sigma_v',num2cell(output(:,5)),...
			'Bz',num2cell(output(:,6)),'Ma',num2cell(output(:,7)),'Mm',num2cell(output(:,8)),...
			'phi',num2cell(output(:,9)),'theta',num2cell(output(:,10)),'Kp',num2cell(output(:,11)),...
			'E_field',num2cell(output(:,12)),'vxBz', num2cell(output(:,13)),'vx',num2cell(output(:,14)));
		save( f_to_save, 'omni_data' ) ;
		
		if save_removed
			removed(:,1) = datenum(removed_dates);
			save(f_to_save2,'removed');
		end
	else
		data_folder = strcat(data_dir,'omni_1min/');
		for year = years
			for month = [1:12]
				f_to_open = strcat(data_folder,sprintf('omni_min%d%02d.asc',year,month)); 
				temp_data = [];
				temp_data = dlmread(f_to_open);
				
				f_to_save = strcat(data_folder,sprintf('prepped/%s_omni_1min_%d_%d_%d',station,window_length/60,year,month));
		
				output = nan(max(size(temp_data)),14);
			
				y = temp_data(:,1);
				d = temp_data(:,2);
				h = temp_data(:,3);
				min = temp_data(:,4);
				dates = [y ones(size(y)) d h min zeros(size(y)) ]; 
				
				% recalculate
				dates = datevec(datenum(dates));
				
				warning('Not surte were using dates properly');
					
		
				
				% fill i the data part
				output(:,2) = temp_data(:,22); % 'speed' the SW speed ~km/sec
				output(:,3) = temp_data(:,28); % 'pressure' the flow pressure ~nPa
				output(:,4) = temp_data(:,26); % 'Np' the proton density, ~#N/cm^3
				output(:,5) = temp_data(:,19); % 'Bz' Bz (GSM) ~nT
				output(:,6) = temp_data(:,31); % 'Ma' Alfven mach number ~#
				output(:,7) = temp_data(:,46); % 'Mm' Magentosonic mach number ~#
				
				output(:,8) = temp_data(:,29); % 'E_field'  ~mV/m
				%output(:,13) = - temp_data(:,25) .* cos(temp_data(:,26)) .* cos(temp_data(:,27)) .*temp_data(:,17) *1e-3; % 'vxBz' E-field due to vx (different to E_field!!) ~mV/m
				%output(:,14) = - temp_data(:,25) .* cos(temp_data(:,26)) .* cos(temp_data(:,27)); % vx ~km /sec
				output(:,9) = temp_data(:,22); % 'vx_gse' ~km /s
				output(:,10) = temp_data(:,23); % 'vy_gse' ~km /s
				output(:,11) = temp_data(:,24); % 'vz_gse' ~km /s
				output(:,12) = temp_data(:,35); % 'xBSN' in GSE, ~Re
				output(:,13) = temp_data(:,36); % 'yBSN' in GSE, ~Re
				output(:,14) = temp_data(:,37); % 'zBSN' in GSE, ~Re
				
				% Notes on OMNI 1-min
				% http://omniweb.gsfc.nasa.gov/html/HROdocum.html
				% They use bow shock model of Farris and Russell (1994) and magnetopause model of Shue et al (1997)
				% to determine where bow shock will be when phase front reaches it. The data is shifted to here (location given 
				% in data)
				%
				% Phase fronts that would overtake/reach each other are both included in the shifted data. No assumption is made
				% on how they interact or what we would see. The parameter "duration between observing times", DBOT, should indicate when 
				% these occur. There is an example of where this is very significant as it means plasma averages are mixed up.
				%
				% The 1min time is teh start of each minute.
				%
				% I'm not sure whether the E-fields in both high and low res are measured or calculated.
				%
				
		
				
				
				
				
				
				
				
				mlts = read_in_mlt_midnight( data_dir, station );
				
				% sort out bad data
				bad_data = output(:,2) >= 9998; 
				bad_data = bad_data | output(:,3) >= 99;
				bad_data = bad_data | output(:,3) == 0; %CHECK THIS WITH MATT
				bad_data = bad_data | output(:,4) >= 999;
				bad_data = bad_data | output(:,4) == 0; %CHECK THIS WITH MATT
				bad_data = bad_data | output(:,5) >= 999;
				bad_data = bad_data | output(:,6) >= 999;
				bad_data = bad_data | output(:,7) >= 99999;
				bad_data = bad_data | output(:,8) >= 99;
				%bad_data = bad_data | output(:,9) > 360;
				%bad_data = bad_data | output(:,9) < 0;
				if save_removed %check what we've thrown out
					removed_dates = dates(bad_data,:);
					removed = output(bad_data,:);
				end
				dates(bad_data,:) = [];
				output(bad_data,:) = [];
				
				% do conversion and sort out datenums for output
				
				if do_mlt_conversion
					dates(:,4) = dates(:,4) - mlts( mlts(:,1)== year, 2 );
				end
				dates(:,5) = floor(dates(:,5)); % just tidying up from MLT conversion I think
				
				
				output(:,1) = datenum( dates ); % do you need an extra datenum(datevec(    )) here to counter changes??
				
				%output(:,3) = convert_Kp( output(:,3) );
				
				omni_data = struct('dates',num2cell(output(:,1)),'speed',num2cell(output(:,2)),...
					'pressure',num2cell(output(:,3)),'Np',num2cell(output(:,4)),...
					'Bz',num2cell(output(:,5)),'Ma',num2cell(output(:,5)),'Mm',num2cell(output(:,7)),...
					'E_field',num2cell(output(:,8)),'vx_gse', num2cell(output(:,9)),'vy_gse',num2cell(output(:,10)),...
					'vz_gse',num2cell(output(:,11)),'xBSN',num2cell(output(:,12)),'yBSN',num2cell(output(:,13)),...
					'zBSN',num2cell(output(:,14))...
					);
				save( f_to_save, 'omni_data' ) ;
			
			end
			
		end
	end
    

end