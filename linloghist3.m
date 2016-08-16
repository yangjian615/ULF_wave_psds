% Calls bin_2d_data by finding sensible bin edges for data logarithmic in one dimension.
% Be aware that this will give a different result than if you specify bins as bin edges may move.


% eg here expect lindata to be SW speed and logdata to be power. nbins should be [a,b]


function [n,xedges,yedges] = linloghist3( lindata, logdata, nbins )

	% set up edges : need one more edge than no. of bins
	xedges = linspace(min(lindata),max(lindata),nbins(1)+1);
	yedges = logspace(-5,10,nbins(2)+1);
	warning('linloghist3:logdata edges not chosen intelligently');
		
	linsize = size(lindata);
	logsize = size(logdata);
	
	if linsize(1) == 1
		lindata = lindata';
	end
	if logsize(1) == 1
		logdata = logdata';
	end
		
	n = bin_2d_data([lindata logdata],xedges,yedges);

	
end