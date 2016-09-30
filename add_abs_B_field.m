% Adds a field for absiolute values of B


function [output] = add_abs_B_field( data )

	ptag = get_ptag();
	do_print(ptag,2,'add_abs_B_field: entering function \n');
	
	all_Bz = cell2mat({data.Bz});
	all_Bx = cell2mat({data.Bx});
	all_By = cell2mat({data.By});
	
	all_absB = sqrt(all_Bz.^2+all_Bx.^2+all_By.^2);
	all_absB = num2cell(all_absB);
	
	output = data;
	[output.absB] = all_absB{:};
	
end