% Adds a field expressing the variation in Bz as a percentage

function [output] = add_sigma_Np_perc_field( data )
	
	ptag = get_ptag();
	do_print(ptag,2,'add_sigma_Np_perc_field: entering function \n');
	
	all_Np = abs(cell2mat({data.Np}));
	all_sNp = cell2mat({data.sigma_Np});
	
	sNp_perc = (all_sNp ./ all_Np)*100;
	sNp_perc = num2cell(sNp_perc);
	
	output = data;
	[output.sigma_Np_perc] = sNp_perc{:};
	
	
end