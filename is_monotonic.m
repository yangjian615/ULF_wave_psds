

function [t_or_f] = is_monotonic( to_check )

	diff = to_check(2:end) - to_check(1:end-1);
	
	t_or_f = sum( diff >= 0 ) == (length(to_check)-1); %true if monotonically increasing
	
end
	