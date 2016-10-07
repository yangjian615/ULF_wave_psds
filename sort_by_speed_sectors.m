% You can use for anything, doens't need to be speed
% returns the quantile values ("speed_quants") and the quantile each data lies in ("whihc_qwuant")
% You can sort into quantiles or into lin/log space using min, max and num_quants

function [speed_quants,which_quant] = sort_by_speed_sectors(data,num_quants,opts)

	ptag = get_ptag();
	do_print(ptag,2,'sort_by_speed_sectors: entering function\n');

	
	% input checks
	% Data
	if length(size(data)) ~=2
		error('sort_by_speed_sectors:BadInputSize');
	elseif sum(size(data)) == 0
		error('sort_by_speed_sectors:BadInput',' no data sent in');
	end
	% Options
	if nargin == 2
		opts = 'quantile';
	elseif ~strcmp(opts,'lin') & ~strcmp(opts,'log') & ~strcmp(opts,'quantile')
		error('sort_by_speed_sectors:BadInput',' incompatible option for sorting bins');
	end

	% find quantiles
	switch opts
		case 'quantile'
			speed_quants = quantile(data,num_quants);
		case 'lin'
			speed_quants = linspace(min(data),max(data),num_quants);
			do_print(ptag,2,'sort_by_speed_sectors: Using linspace instead of quantile stuff');
		case 'log'
			speed_quants = logspace(log10(min(data)),log10(max(data)),num_quants);
			do_print(ptag,2,'sort_by_speed_sectors: Using logspace instead of quantile stuff');
	end
	
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
	
	% and check we got them all. Warning/error dep on sorting type
	switch opts
		case 'quantile'
			if sum(isnan(which_quant)) > 0
				warning('sort_by_speed_sectors:BadSorting','some data not labelled as a sector');
			end
	
			% check we got right amount within each 
			for c_count = 1:num_quants+1
				if abs( sum(which_quant==c_count) - ceil(length(data)/(num_quants+1) ) ) > 1
					warning('sort_by_speed_sectors:PoorQuantileSorting','not the same amount in each quantile!');
				end
			end
		
		case {'lin','log'}
			if sum(isnan(which_quant)) > 0
				error('sort_by_speed_sectors:BadSorting','some data not labelled as a sector');
			end
	end
			
	
end
	