% gets the histogram, fixing MATLAB bugs
% note that pcolor removes a column and a row and uses bins/edges weirdly. See your pcolor note off internet.

function [n,xedges,yedges] = linlinhist3( lindata1, lindata2, nbins )

	
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
			
		n = hist3([lindata1,lindata2],'Edges',{xedges yedges});% hold on;
		
		
		% get rid of stupid extra empy bins that are confusing
		n = n(1:nbins(1),1:nbins(2));

		%n_flat = reshape(n,[],1);
		%n1 = n';
		%[xb,yb] = meshgrid(xedges,yedges); % for plotting, if you want
		%disp(max(xb));
end