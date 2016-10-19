% You can use for anything, doens't need to be speed
% returns the quantile values ("speed_quants") and the quantile each data lies in ("whihc_qwuant")
% You can sort into quantiles or into lin/log space using min, max and num_quants
% num_quants giove you the final number of bins, no mattter the method
%of speed_quants, first will be min and last will be max

function [speed_quants,which_quant] = sort_by_speed_sectors(data,num_quants,opts)

	ptag = get_ptag();
	do_print(ptag,2,'sort_by_speed_sectors: entering function\n');

	
	% input checks
	% Data
	if length(size(data)) ~=2
		error('sort_by_speed_sectors:BadInputSize');
	elseif sum(size(data)) == 0
		error('sort_by_speed_sectors:BadInput',' no data sent in');
	elseif sum(isnan(data)) > 0
		error('sort_by_speed_sectors:BadInput',' havent built this to deal with  Nans yet');
	end
	% Options
	if nargin == 2
		opts = 'quantile';
	elseif ~strcmp(opts,'lin') & ~strcmp(opts,'log') & ~strcmp(opts,'quantile')
		error('sort_by_speed_sectors:BadInput',' incompatible option for sorting bins');
	end

	% find quantiles/ bins. 
	switch opts
		case 'quantile'
			speed_quants = quantile(data,num_quants-1);
			speed_quants = cat(2,min(data),speed_quants,max(data));
			do_print(ptag,3,'sort_by_speed_sectors: Sorted using quantiles \n');
		case 'lin'
			speed_quants = linspace(min(data),max(data),num_quants+1);
			do_print(ptag,3,'sort_by_speed_sectors: Using linspace instead of quantile stuff \n');
		case 'log'
			speed_quants = logspace(log10(min(data)),log10(max(data)),num_quants+1);
			do_print(ptag,3,'sort_by_speed_sectors: Using logspace instead of quantile stuff \n');
	end
	
	% % edges of "quantile bins"
	% all_speed_quants = [min(data), speed_quants, max(data)];
	% do_print(ptag,4,sprintf('sort_by_speed_sectors: have %d edges of quantile bins, hence %d bins \n',length(all_speed_quants),length(all_speed_quants)+1));
	
	% what to work out which is in each quantile bin
	which_quant = nan(size(data));
	in_this = false(size(data));

	for sector = [1:num_quants] %teh numbe rof bins
		do_print(ptag,4,sprintf('sort_by_speed_sectors: doing for bin number %d \n',sector));
		in_this = false(size(data));
		
		% careful wth edges of bins
		if sector < num_quants
			in_this = data >= speed_quants(sector) & data < speed_quants(sector+1);
		else
			in_this = data >= speed_quants(sector) & data <= speed_quants(sector+1);
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
				disp(data(isnan(which_quant)));
				error('sort_by_speed_sectors:BadSorting','some data not labelled as a sector');
			end
	end
			
	
end
	