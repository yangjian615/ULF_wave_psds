

function [output] = lin_edges_to_mids( edges )
% shortens a vecotr by finding midpoint between points. Designed for use of binned histogram data, which 
% returns edges of bins. To overlay curves, points etc we need to also know the centres of the bins.

	output=nan(1,length(edges)-1);
	
	for ed_count = [1:length(edges)-1]
		output(ed_count) = mean(edges(ed_count:ed_count+1));
	end
	
	
	if sum(isnan(output)) > 0
		error('Didnt find good centres');
	end
	
end