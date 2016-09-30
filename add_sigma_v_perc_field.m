% Adds a field expressing the variation in solar wind speed as a percentage

function [output] = add_sigma_v_perc_field( data )
	
	ptag = get_ptag();
	do_print(ptag,2,'add_sigma_v_perc_field: entering function \n');
	
	all_speed = cell2mat({data.speed});
	all_sv = cell2mat({data.sigma_v});
	
	sv_perc = (all_sv ./ all_speed)*100;
	sv_perc = num2cell(sv_perc);
	
	output = data;
	[output.sigma_v_perc] = sv_perc{:};
	
	
end