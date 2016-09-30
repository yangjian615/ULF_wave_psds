% Adds a field expressing the variation in Bz as a percentage

function [output] = add_sigma_Bz_perc_field( data )
	
	ptag = get_ptag();
	do_print(ptag,2,'add_sigma_Bz_perc_field: entering function \n');
	
	all_Bz = abs(cell2mat({data.Bz}));
	all_sBz = cell2mat({data.sigma_Bz});
	
	sBz_perc = (all_sBz ./ all_Bz)*100;
	sBz_perc = num2cell(sBz_perc);
	
	output = data;
	[output.sigma_Bz_perc] = sBz_perc{:};
	
	
end