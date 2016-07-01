% Find the required frequencies given a window and two consecutive times in window

% We expect "data" to be 1d. The times are the corresponding timestamp or ust feed in two times if you want.
% This now matches up with those from multitaper method, except we automatically apply the 1e3 scaling here 
% which must be done manually there.

function [freqs] = calcfreqs( data, times, scaling )
%eg enter (d(1).x,d(1),times,[])
	

	if isempty(scaling)
		scaling = 1e3;
	end

	time1 = times(1);
	time2 = times(2);
	
	N = length( data );
	n = [0:N/2];
	
	t_res = abs(etime(datevec(time1),datevec(time2))); % in seconds

	f_res = 1/(N*t_res);
	freqs = f_res*n*scaling; %in mHz
	
end