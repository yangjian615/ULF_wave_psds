% What is the value at which given percentage is lower?
% Built from top_straight_line but method is different: takes the list of values, orders them and finds the one in 
% whatever position counts for that percentage through. 

% ys: list of values
% rw: ratio wanted 

function [val] = top_straight_line_new(ys,rw)
	
	val = [];
	
	sorted = sort(ys);
	
	pos_exact = length(ys)*rw; %exactly what position is this?
	pos_ints = [1:length(ys)];
	difference = abs(pos_ints - pos_exact);
	
	pos_use = round(median(pos_ints(difference ==  min(difference))));
	% what integer posintion is this closest to? (could interpolate but too much effort)
	% have used round in case we get exactly between two points
	
	if length(pos_use) ~= 1
		disp(length(ys));
		disp(pos_use);
		error('wRONG!');
	end
	
	val = sorted(pos_use);
	
end
	