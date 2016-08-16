% gets the histogram, fixing MATLAB bugs by using own code
% note that pcolor removes a column and a row and uses bins/edges weirdly. See your pcolor note off internet.

function [n,xedges,yedges] = linlinhist3( lindata1, lindata2, nbins )

		% set up edges : need one more edge than no. of bins
		xedges = linspace(min(lindata1),max(lindata1),nbins(1)+1);
		yedges = linspace(min(lindata2),max(lindata2),nbins(2)+1);
		
			
		linsize1 = size(lindata1);
		linsize2 = size(lindata2);
		
		if linsize1(1) == 1
			lindata1 = lindata1';
		end
		if linsize2(1) == 1
			lindata2 = lindata2';
		end
			
		n = bin_2d_data([lindata1 lindata2],xedges,yedges);
		
		
		
		
end