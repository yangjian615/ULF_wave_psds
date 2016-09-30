% Adds a field for absiolute values of Bx


function [output] = add_abs_Bx_field( data )

	ptag = get_ptag();
	do_print(ptag,2,'add_abs_Bx_field: entering function \n');
	
	all_Bx = cell2mat({data.Bx});
	all_absBx = num2cell(abs(all_Bx));
	
	output = data;
	[output.absBx] = all_absBx{:};
	
end