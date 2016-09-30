

function [output] = add_requested_fields( data, req_fields, ddir, data_opts )

	ptag = get_ptag();
	do_print(ptag,2,'add_requested_fields: entering fn \n');

	check_basic_struct(req_fields,'add_omni_extras');
	
	fnames = fieldnames(req_fields);
	output = data;
	
	for f_count = 1:length(fnames)
		f_n = fnames{f_count};
		
		% add stuff if this field is requested
		if req_fields.(f_n) & ~isfield(data,f_n)
			add_fn = str2func(sprintf('add_%s_field',f_n));

			% separate cases where extra input needed
			if strcmp(f_n,'L')  | strcmp(f_n,'MLT_val')
				output = add_fn(output, ddir,data_opts);
			else
				output = add_fn(output);
			end
		end
	end
	
end
		