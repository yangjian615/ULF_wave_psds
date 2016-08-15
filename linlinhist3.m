% gets the histogram, fixing MATLAB bugs
% note that pcolor removes a column and a row and uses bins/edges weirdly. See your pcolor note off internet.

function [n,xedges,yedges] = linlinhist3( lindata1, lindata2, nbins )

	
		xedges = linspace(min(lindata1),max(lindata1),nbins(1)+1);
		yedges = linspace(min(lindata2),max(lindata2),nbins(2)+1);
		
		disp(xedges);
		disp(yedges);
			
		linsize1 = size(lindata1);
		linsize2 = size(lindata2);
		
		if linsize1(1) == 1
			lindata1 = lindata1';
		end
		if linsize2(1) == 1
			lindata2 = lindata2';
		end
			
		n = hist3([lindata1,lindata2],'Edges',{xedges yedges});% hold on;
		%warning: don't really understand what matlab is doing here. Suggest rewriting to use bin_2d_data instead
		% Actaully I think matlab is adding in extra bins on both sides to include maximum and minimum
		warning('linlinhist3:BadMATLABBinningUsed');
		
		
		% get rid of stupid extra empy bins that are confusing
		n = n(1:nbins(1),1:nbins(2)); 
		
		
		
		
end