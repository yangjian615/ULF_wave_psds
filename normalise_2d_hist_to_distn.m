% Normalises by amount of data in that speed bin and then by overall amount of data
% Expecting a 2d matrix where values are counts (eg from linloghist3)
% Expect to sum over second coordinate

function [n_norm,only_bin_normalised] = normalise_2dhist_to_distn( n )

	nbins = size(n);
	
	% first normalise by bin counts
	n_norm = zeros(nbins);
	for bin_count = [1:nbins(1)]
		if sum(n(bin_count,:)) > 0
			n_norm(bin_count,:) = n(bin_count,:)/(sum(n(bin_count,:))); 
		end
	end
	
	only_bin_normalised = n_norm;
	
	count_total = sum(sum(n_norm));
	n_norm = n_norm/count_total;
	
end