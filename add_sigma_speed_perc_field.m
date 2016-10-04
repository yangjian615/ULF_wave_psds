% Adds a field expressing the variation in solar wind speed as a percentage
% Note sigma_v is the OMNI one,; my calculated version is sigma_speed

function [output] = add_sigma_speed_perc_field( data )
	
	ptag = get_ptag();
	do_print(ptag,2,'add_sigma_speed_perc_field: entering function \n');
	
	all_speed = cell2mat({data.speed});
	all_sv = cell2mat({data.sigma_speed});
	
	sv_perc = (all_sv ./ all_speed)*100;
	sv_perc = num2cell(sv_perc);
	
	output = data;
	[output.sigma_speed_perc] = sv_perc{:};
	
	
end