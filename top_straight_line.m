% What is the straight line such that the given ratio of data lies underneath?

function [bval,fval] = top_straight_line(xs,ys,rw)

	ratio_below = @(b) ( abs( sum( ys <= b )/length(ys) - rw ) );
	
	% you need to improve this by taking several start points and taking mode. Stupid MATLAB not workgin properly
	start_pts = linspace(0.2,14,5);
	results = nan(length(start_pts),2);
	
	for start_count = [1:length(start_pts)]
		start_pt = start_pts(start_count);
		[bval,fval] = fminsearch(ratio_below,start_pt);
		results(start_count,:) = [bval, fval];
	end
	
	if length(results) ~= length(start_pts)
		error('>> something wrong with results before taking median <<');
	end
	
	results = median(results);
	
	if length(results) ~= 2
		error('>>something wrogn with results<<');
	end
	
	bval = results(1);
	fval = results(2);
	
	%plot(xs,bval*ones(size(xs)),'r');
end
	