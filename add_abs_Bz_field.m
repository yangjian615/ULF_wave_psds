% Adds a field for absiolute values of Bz


function [output] = add_abs_Bz_field( data )

	ptag = get_ptag();
	do_print(ptag,2,'add_abs_Bz_field: entering function \n');
	
	all_Bz = cell2mat({data.Bz});
	
	all_absBz = abs(all_Bz);
	all_absBz = num2cell(all_absBz);
	
	output = data;
	[output.absBz] = all_absBz{:};
	
end