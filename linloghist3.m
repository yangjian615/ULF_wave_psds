% gets the histogram where one of the sets of bin edges need to be logarithmic
% eg here expect lindata to be SW speed and logdata to be power. nbins should be [a,b]

function [n,xbb,ybb,n1,xb,yb,n_flat,xedges,yedges] = linloghist3( lindata, logdata, nbins )

		xedges = linspace(min(lindata)-1,max(lindata)+1,nbins(1));
		yedges = logspace(-5,10,nbins(2));
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
		n_flat = reshape(n,[],1);
		n1 = n';
		n1(size(n,2) + 1, size(n,1) + 1) = 0;
		xbb = linspace(min(lindata),max(lindata),size(n,1)+1);
		ybb = logspace(-5,10,size(n,2)+1);
		warning('>> I think the xbb,ybb edges are off, dont understand them <<');
		[xb,yb] = meshgrid(xbb,ybb); % for plotting, if you want
end