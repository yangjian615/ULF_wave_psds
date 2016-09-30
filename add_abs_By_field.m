% Adds a field for absiolute values of By


function [output] = add_abs_By_field( data )

	ptag = get_ptag();
	do_print(ptag,2,'add_abs_Bx_field: entering function \n');
	
	all_By = cell2mat({data.By});
	all_absBy = num2cell(abs(all_By));
	
	output = data;
	[output.absBy] = all_absBy{:};
	
end