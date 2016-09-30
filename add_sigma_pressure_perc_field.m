% Adds a field expressing the variation in pressure as a percentage

function [output] = add_sigma_pressure_perc_field( data )
	
	ptag = get_ptag();
	do_print(ptag,2,'add_sigma_Np_perc_field: entering function \n');
	
	all_pressure = abs(cell2mat({data.pressure}));
	all_spressure = cell2mat({data.sigma_pressure});
	
	spressure_perc = (all_spressure ./ all_pressure)*100;
	spressure_perc = num2cell(spressure_perc);
	
	output = data;
	[output.sigma_pressure_perc] = spressure_perc{:};
	
	
end