% Prints out depending on numbered tag.

function [] = do_print( var_tag, num_tag, disp_string )
	
	if var_tag >= num_tag
		fprintf(disp_string);
	end

end