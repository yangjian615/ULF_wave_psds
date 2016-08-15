% gets the histogram where one of the sets of bin edges need to be logarithmic
% eg here expect lindata to be SW speed and logdata to be power. nbins should be [a,b]

% OLD OUTPUT: [n,xbb,ybb,n1,xb,yb,n_flat,xedges,yedges] This was changed because MATLAB adds in an extra histogram row????

function [n,xedges,yedges] = linloghist3( lindata, logdata, nbins )


	xedges = linspace(min(lindata),max(lindata),nbins(1)+1);
	yedges = logspace(-5,10,nbins(2)+1);
	warning('>> logdata edges not chosen intelligently <<');
		
	linsize = size(lindata);
	logsize = size(logdata);
	
	if linsize(1) == 1
		lindata = lindata';
	end
	if logsize(1) == 1
		logdata = logdata';
	end
		
	n = hist3([lindata,logdata],'Edges',{xedges yedges});% hold on;
	
	%warning: don't really understand what matlab is doing here. Suggest rewriting to use bin_2d_data instead
	warning('linlinhist3:BadMATLABBinningUsed');
	
	% get rid of stupid extra empy bins that are confusing
	n = n(1:nbins(1),1:nbins(2));

	
end