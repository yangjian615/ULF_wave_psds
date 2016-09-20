% Expects all data to be the same for each station.
% ddir : location for final data
% filename : raw text file from http://omniweb.gsfc.nasa.gov/cgi/vitmo
% station : station to create name

function [station_data] = station_text_data_to_struct( ddir, filename, station )
	
	input_data = dlmread(filename);
	
	% We expect format of:
	% col1: Year
	% col2: Corrected geomagnetic latitude, deg
	% col3: CGM longitude, deg
	% col4: declination, deg
	% col5: MLT, UT
	% col6: L value, Re
	
	station_data = [];
	

	years = num2cell(input_data(:,1));
	[station_data(1:size(input_data,1)).year] = years{:};
	
	CGM_lat = num2cell(input_data(:,2));
	[station_data.CGM_lat] = CGM_lat{:};
	
	CGM_lon = num2cell(input_data(:,3));
	[station_data.CGM_lon] = CGM_lon{:};
	
	decs = num2cell(input_data(:,4));
	[station_data.decs] = decs{:};
	
	MLTs = num2cell(input_data(:,5));
	[station_data.MLT] = MLTs{:};
	
	Ls = num2cell(input_data(:,6));
	[station_data.L] = Ls{:};
	
	
	save(strcat(ddir,sprintf('%s_data_struct',station)),'station_data');
	
	
end
	