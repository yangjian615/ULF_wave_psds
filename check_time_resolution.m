% Takes in a column of datevec, checks all entries are separated by integer amounts
% of the given time resolution (in seconds)

function [] = check_time_resolution(to_check,time_res)
	
	%check orientation
	if size(to_check,2) ~= 6 
		disp(size(to_check));
		error('Unexpected size of datevecs to check');
	end
		
	
	check1 = to_check(1:end-1,:);
	check2 = to_check(2:end,:);
	check_res = mod(abs(etime(check2,check1)),time_res);
	
	if sum(check_res) > 0
		disp(sum(check_res ~= 0));
		%disp(unique(check_res));
		error('Bad time resolution between data points');
	end
	
end