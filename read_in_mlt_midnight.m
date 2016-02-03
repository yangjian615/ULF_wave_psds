% This reads in the mlt midnights from
% http://omniweb.gsfc.nasa.gov/vitmo/cgm_vitmo.html
% which is in format
% YEAR     MLT MIDNIGHT IN UT
% YEAR     MLT MIDNIGHT IN UT 
% YEAR     MLT MIDNIGHT IN UT
% YEAR     MLT MIDNIGHT IN UT


function output = read_in_mlt_midnight( data_dir, station )

    filename = strcat(data_dir,sprintf('%s_mlt_midnights.txt',station));
    temp_data = dlmread(filename);
    
    output = temp_data;

end