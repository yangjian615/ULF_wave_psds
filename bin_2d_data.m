% Just a tester to start with to get proper histogram/binned data
% We expect data to have two columns, then two vecotrs containing the edges

function [output] = bin_2d_data( data, edges1, edges2 )

	nbins1 = length(edges1);
	nbins2 = length(edges2);

	% check we have the right data
	if size(data,2) ~= 2
		error('bin_2d_data:not2Ddata');
	end
	
	if max(data(:,1)) > max(edges1)
		warning('bin_2d_data:UncontainedExtremeValue',' max of first col not in edges');
	end
	if max(data(:,2)) > max(edges2)
		warning('bin_2d_data:UncontainedExtremeValue',' max of second col not in edges');
	end
	if min(data(:,1)) < min(edges1)
		warning('bin_2d_data:UncontainedExtremeValue',' min of first col not in edges');
	end
	if min(data(:,2)) < min(edges2)
		warning('bin_2d_data:UncontainedExtremeValue',' min of second col not in edges');
	end
	
	% initialise the output. Since we've specififed edges we expect one dim less of bins
	binned = zeros(nbins1-1,nbins2-1);
	
	% run through each bin, see how many we have in each
	for b1count = 1:nbins1-1
	
		in_bin1 = (data(:,1) >= edges1(b1count)) & (data(:,1) < edges1(b1count+1));
		if b1count == (nbins1-1)
		% if we are accepting one edge of bins must also accept the very end, see test 5
			in_bin1 = (data(:,1) >= edges1(b1count)) & (data(:,1) <= edges1(b1count+1));
		end
		
		for b2count = 1:nbins2-1
			
			in_bin2 = (data(:,2) >= edges2(b2count)) & (data(:,2) < edges2(b2count+1));
			if b2count == (nbins2-1)
			% if we are accepting one edge of bins must also accept the very end, see test 5
				in_bin2 = (data(:,2) >= edges2(b2count)) & (data(:,2) <= edges2(b2count+1));
			end
			in_both = in_bin1 & in_bin2;
			binned(b1count,b2count) = sum( sum( in_both ));
		end
	end
	
	%check result
	if sum(sum(binned)) ~= length(data)
		warning('bin_2d_data:DoesntAddUp',' total data before and after are different');
		% only a warning as it may be intentional (see min/max checks above too)
	end
		
	
	output = binned;
	
end
	