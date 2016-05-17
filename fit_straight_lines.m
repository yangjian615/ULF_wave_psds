% we can split the data into one line or two or three sublines. This will do all of tehm.

function [tse,trmse,fit1,fit2,fit3,gof1,gof2,gof3] = fit_straight_lines(xs,ys,numlines,sp1,sp2,do_plot)

	% initialise output as it may be empty
	tse = []; trmse = [];
	fit1 = []; fit2 = []; fit3 = [];
	gof1 = []; gof2 = []; gof3 = [];

	if numlines ==1 
		x1 = xs;
		y1 = ys;
	elseif numlines == 2
		x1 = xs( xs<= sp1);
		y1 = ys( xs<=sp1 );
		
		x2 = xs( xs >= sp1 );
		y2 = ys( xs >= sp1 );
	elseif numlines ==3
		x1 = xs( xs<= sp1);
		y1 = ys( xs<=sp1 );
		
		x2 = xs( xs >= sp1 & xs<= sp2 );
		y2 = ys( xs >= sp1 & xs<= sp2 );
	
		x3 = xs( xs >= sp2 );
		y3 = ys( xs >= sp2 );
	end
	
	
	[fit1,gof1] = fit(x1,y1,'a*x+b','StartPoint',[-2 5]);
	
	if numlines > 1
		[fit2,gof2] = fit(x2,y2,'a*x+b','StartPoint',[-2 3]);
	end
	if numlines > 2
		[fit3,gof3] = fit(x3,y3,'a*x+b','StartPoint',[-2 1]);
	end
	
	if numlines == 1
		tse = gof1.sse;
		trmse = gof1.rmse;
	elseif numlines == 2
		tse = gof1.sse+gof2.sse;
		trmse = (gof1.rmse+gof2.rmse)/2;
	elseif numlines == 3
		tse = gof1.sse+gof2.sse+gof3.sse;
		trmse = (gof1.rmse+gof2.rmse+gof3.rmse)/3;
	end
	
	
	if do_plot
		
		figure(1);
		
		%plot(xs,ys,'.'); hold on;
		x1 = linspace(x1(1),x1(length(x1)),50);
		plot(x1,fit1(x1),'r');
		
		if numlines > 1
			x2 = linspace(x2(1),x2(length(x2)),50);
			plot(x2,fit2(x2),'b');
			plot(x2(1),y2(1),'ok');
		end
		if numlines > 2 
			x3 = linspace(x3(1),x3(length(x3)),50);
			plot(x3,fit3(x3),'g');
			plot(x3(1),y3(1),'ok');
		end
		
		
		axis([0.1,2.8,-10,12]);
		
	end
	
end