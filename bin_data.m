% bin teh given data using the given limits - this includes a bin for larger than last and smaller than first values.

function [output] = bin_data( data_to_bin, bin_limits )

	num_bins = length(bin_limits)+1;
	
	output = nan(size(data_to_bin));
	
	% do the end bins first
	output( data_to_bin < bin_limits(1) ) = 1;
	output( data_to_bin >= bin_limits( length(bin_limits) ) ) = num_bins;
	
	% now all the others
	for bin = [2:num_bins - 1]
		bin_lo = bin_limits(bin-1);
		bin_hi = bin_limits(bin);
		
		output( (data_to_bin >= bin_lo) & (data_to_bin < bin_hi) ) = bin;
	end
	
	% now check it
	if sum(isnan(output)) > 0
		error('>>> Not binned properly - you missed some!<<<');
	end


end