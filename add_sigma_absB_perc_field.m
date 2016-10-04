% Adds a field expressing the variation in Bz as a percentage

function [output] = add_sigma_absB_perc_field( data )
	
	ptag = get_ptag();
	do_print(ptag,2,'add_sigma_absB_perc_field: entering function \n');
	
	if ~isfield(data,'absB')
		data = add_abs_B_field( data );
	end
	
	all_B = cell2mat({data.absB});
	all_sB = cell2mat({data.sigma_B}); %sigma_absB is the low-res omni one but there are big gaps. sigma_B is calculated from highres B values
	
	
	warning('add_sigma_absB_perc_field: which sigma B definition to use???');
	
	sB_perc = (all_sB ./ all_B)*100;
	sB_perc = num2cell(sB_perc);
	
	output = data;
	[output.sigma_absB_perc] = sB_perc{:};
	
	
end