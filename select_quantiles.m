% "selections" should be a cell, where each entry is a set {'ofield',num_quants,[which quants]} eg {'Np',6,[1]} would return the first sextile of Np data.
% note that we don't save the sorted sectors which may save much time later on.


function [output] = select_quantiles( data, selections )
	
	
	ptag = get_ptag();
	do_print(ptag,2,'select_quantiles: entering function\n');
	%do_print(ptag,3,char(selections{:}));
	%selections{:}

	
	sorting = data;
	
	% check input is as expected
	if ~isstruct(data)
		error('select_quantiles:BadInputType','data not a struct');
	end

	check_basic_struct(selections,'quantile_selections');
	
	do_print(ptag,3,sprintf('select_quantiles: %d conditions on this data \n',length(selections)));
	
	for s_count = 1:length(selections)
	
		o_f = selections(s_count).o_f;
		num_quants = selections(s_count).num_quants;
		which_quants = selections(s_count).which_quants;

		do_print(ptag,4,sprintf('select_quantiles: field %s, %d quantiles \n',o_f,num_quants));
		
		[quant_vals,quants_sectors] = sort_by_speed_sectors(cell2mat({sorting.(o_f)}),num_quants);
		
		keep_vals = false(size(sorting));
		
		for keep_count = 1:length(which_quants)
			keep_vals = keep_vals | (quants_sectors == which_quants(keep_count));
		end
		
		sorting = sorting(keep_vals);
	end
	
	output = sorting;
	
end
		
		
		
