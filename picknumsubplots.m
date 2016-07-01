
% hand in how many total, pick sensible number of plots

function [pl_rows,pl_cols] = picknumsubplots( numplots )
	
	if numplots > 50
		warning('>>> trying to plot too many! <<<');
	end
	
	if false %old, testing without
		if ceil(numplots/5) >= 5
			pl_rows = 5;
			pl_cols = ceil(numplots/5);
		elseif ceil(numplots/5) ==4 
			pl_rows = 5;
			pl_cols = 4;
		elseif ceil(numplots/4) ==3
			pl_rows = 4;
			pl_cols = 3;
		elseif ceil(numplots/4) ==2
			pl_rows = 4;
			pl_cols = 2;
		elseif ceil(numplots/3) ==2
			pl_rows = 3;
			pl_cols = 2;
		elseif ceil(numplots/2) == 2
			pl_rows = 2;
			pl_cols = 2;
		elseif numplots/2 == 1
			pl_rows = 2;
			pl_cols = 1;
		elseif numplots ==1
			pl_rows = 1;
			pl_cols = 1;
		else
			disp(numplots);
			error('missed case, couldnt plot');
		end
	end
	
	if numplots == 1
		pl_rows = 1;
		pl_cols =1 ;
	elseif numplots == 2
		pl_rows = 1;
		pl_cols = 2;
	elseif numplots <= 4
		pl_rows = 2;
		pl_cols = 2;
	elseif numplots <= 6
		pl_rows = 2;
		pl_cols = 3;
	elseif numplots <= 8
		pl_rows = 2;
		pl_cols = 4;
	elseif numplots == 9 
		pl_rows = 3;
		pl_cols = 3;
	elseif numplots <= 12
		pl_rows = 3;
		pl_cols = 4;
	elseif numplots <= 15
		pl_rows = 3;
		pl_cols = 5;
	elseif numplots <= 21
		pl_rows = 4;
		pl_cols = 5;
	elseif numplots <= 26
		pl_rows = 4;
		pl_cols = 6;
	else
		disp(numplots);
		error('missed case, couldnt plot');
	end
		
end