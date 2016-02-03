% Bins the solar wind data so you have integer values.
% We just expect the solar wind speed column

function output = bin_sw_speed( input )
    output = nan(size(input));

    output( (input(:) < 300) ) = 1;
    output( (input(:) >= 300) & (input(:) < 400) ) = 2;
    output( (input(:) >= 400) & (input(:) < 500) ) = 3;
    output( (input(:) >= 500) & (input(:) < 600) ) = 4;
    output( (input(:) >= 600) & (input(:) < 700) ) = 5;
    output( (input(:) >= 700) ) = 6;
    
end
