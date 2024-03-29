% Does the bulk of the preprocessing for data. Align X,Y coords properly
% with magnetic north, covnert to magnetic local time, create a datenum
% column and calculate the datevec part again properly after the
% conversion.

% HISTORY
% 16-01-04 No longer rotates to magnetic north - assume this is already
% done. ALso remove check for pre-existing file - ALWAYS replace if
% function called, still checks loading file is OK.
% 16-01-12 Rotate to magnetic north again.
% 16-02-03 Slightly change where data is stored

function [output_data] = data_prep(data,data_dir,get_opts,this_year)

	ptag = get_ptag();
	do_print(ptag,2,'data_prep: entering function\n');
    do_mlt_conversion = true; %THESE SHOULD BOTH BE TRUE ALMOST ALWAYS
    do_mag_rot = true;
	
    
    function output = rotate_to_mag_north( this_year, input, decs ) 
		%so the X will point to magnetic north and Y will be perp to this (ie x~ H and y~D, pointing to geomag East:we)
        
		% copied in from setup_C_data
        % this only deals with the X,Y columns (so inout should only have
        % two cols)
        
        this_dec = decs( decs(:,1) == this_year, 2);
        
        this_dec = deg2rad(this_dec);
        
        rot_matrix = [ cos(this_dec) sin(this_dec); -sin(this_dec) cos(this_dec) ];
        temp_XY = input';
        
        output = (rot_matrix*temp_XY)';
        
    end
  
	station = get_opts.station;

	
	% load in details of station
	station_data =[];
	load(strcat(data_dir,sprintf('%s_data_struct',station))); % get station_data
    decs(:,1) = cell2mat({station_data.year}); decs(:,2) = cell2mat({station_data.decs}); %lazy here to stick with older formatting
    mlts(:,1) = cell2mat({station_data.year}); mlts(:,2) = cell2mat({station_data.MLT});
	

	% remove empty rows. Remember we made the matrix from zeroes in Python
	empty_rows = sum(data,2) == 0;
	data(empty_rows,:) = [];
	
	% only continue if we have data!
	if sum(sum(data)) == 0
		do_print(ptag,2,'No data for this month!');
	else
		% prepare to align properly with magnetic north
		% make sure you are rotating X,Y!! and subtracting hour correctly!!
		rot_col_1 = min(size(data))-2;
		rot_col_2 = min(size(data))-1;
	
		if do_mag_rot
			data(:,rot_col_1:rot_col_2)  = rotate_to_mag_north( this_year, data(:,rot_col_1:rot_col_2), decs );
		end

		% convert to magnetic local time
		if do_mlt_conversion
			to_subtract = mlts( mlts(:,1) == this_year,2 );
			data(:,4) = data(:,4)-to_subtract;
			data(:,1:6) = datevec(datenum(data(:,1:6)));
		end

		% make sure seconds are all multiples of 5 - sometimes they
		% reset it funny
		data(:,6) = data(:,6) - mod(data(:,6),5);


		% add column just for datenum to the front, recalculate datevec
		data_size = size(data);
		temp = nan( data_size(1), data_size(2)+1 );
		temp(:,2:data_size(2)+1) = data(:,1:data_size(2));
		temp(:,1) = datenum(data(:,1:6));
		data = temp;
		clearvars('temp');
		data(:,2:7) = datevec( data(:,1) );
	
		% sort so ordered by datenum
		data = sortrows(data,1);
	end
		
	output_data = data;

end