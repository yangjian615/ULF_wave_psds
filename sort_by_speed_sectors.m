% You can use for anything, doens't need to be speed
% returns the quantile values ("speed_quants") and the quantile each data lies in ("whihc_qwuant")

function [speed_quants,which_quant] = sort_by_speed_sectors(data,num_quants)

	ptag = get_ptag();
	do_print(ptag,2,'sort_by_speed_sectors: entering function\n');

	if length(size(data)) ~=2
		error('sort_by_speed_sectors:BadInputSize');
	end

	% find quantiles
	speed_quants = quantile(data,num_quants);
	
	% edges of "quantile bins"
	all_speed_quants = [min(data), speed_quants, max(data)];
	do_print(ptag,4,sprintf('sort_by_speed_sectors: have %d edges of quantile bins, hence %d bins \n',length(all_speed_quants),length(all_speed_quants)+1));
	
	% what to work out which is in each quantile bin
	which_quant = nan(size(data));
	in_this = false(size(data));

	for sector = [1:num_quants+1] %you get one more sector than number fo quantiles
		do_print(ptag,4,sprintf('sort_by_speed_sectors: doing for quantile sector %d \n',sector));
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
	
	% check we got right amount within each 
	for c_count = 1:num_quants+1
		if abs( sum(which_quant==c_count) - ceil(length(data)/(num_quants+1) ) ) > 1
			warning('sort_by_speed_sectors:PoorQuantileSorting','not the same amount in each quantile!');
		end
	end
	
end
	