% You can use for anything, doens't need to be speed
% returns the quantile values ("speed_quants") and the quantile each data lies in ("whihc_qwuant")

function [speed_quants,which_quant] = sort_by_speed_sectors(data,num_quants)

	if length(size(data)) ~=2
		error('sort_by_speed_sectors:BadInputSize');
	end


	speed_quants = quantile(data,num_quants);
	all_speed_quants = [min(data), speed_quants, max(data)];
	
	which_quant = nan(size(data));
	in_this = false(size(data));

	for sector = [1:num_quants+1] %you get one more sector than number fo quantiles
		in_this = false(size(data));
	
		min_sector = all_speed_quants(sector);
		max_sector = all_speed_quants(sector+1);
		
		if sector < num_quants+1
			in_this = data >= min_sector & data < max_sector;
		else
			in_this = data >= min_sector & data <= max_sector;
		end
		
		which_quant(in_this) = sector;
	end
	
	% and check we got them all 
	if sum(isnan(which_quant)) > 0
		warning('sort_by_speed_sectors:BadSorting','some data not labelled as a sector');
	end
	
end
	