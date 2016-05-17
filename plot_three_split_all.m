% numlines is number of lines to fit

function [] = plot_three_split_all( numlines, ddir,station,y,m,of,pop,coord,meds)

	close

	if isempty(meds)
		if strcmp(of,'speed') & strcmp(pop,'ps')
			f_to_load = strcat(ddir,sprintf('%s_medians_%s_%s',station,of,pop));
			load(f_to_load);
		else
			[meds,bins] = get_psd_medians(ddir,station,y,m,of,pop);
		end
	end
	
	do_plot = true;
	error_type = 'rmse';
	%coord = 2;
	
	if numlines >1 
		f_to_load = strcat(ddir,sprintf('all_midnight_%dfits_%s_%d',numlines,station,coord));
		load(f_to_load);
		% this data just shows the error values when we split at those indices. So smallest value in matrix indicates where to split for best fit
		
		if strcmp(error_type,'sse')
			errors = se;
		elseif strcmp(error_type,'rmse')
			errors = rse;
		end
	end
	
	freqs = [0:359]*1e3*(1/(720*5));
	
	f1 = freqs(freqs>0.9 & freqs<=15);
	
	ds = nan(length(f1),6); % one for each SW bin, only take freq values in our window
	ds(:,1) = meds(freqs>0.9 & freqs<=15,coord,4,1);
	ds(:,2) = meds(freqs>0.9 & freqs<=15,coord,4,2);
	ds(:,3) = meds(freqs>0.9 & freqs<=15,coord,4,3);
	ds(:,4) = meds(freqs>0.9 & freqs<=15,coord,4,4);
	ds(:,5) = meds(freqs>0.9 & freqs<=15,coord,4,5);
	ds(:,6) = meds(freqs>0.9 & freqs<=15,coord,4,6);
	
	
	if do_plot
		h = figure(1);
		%subplot(2,1,1);
		plot(log(f1),log(ds(:,1)),'.'); hold on;
		plot(log(f1),log(ds(:,2)),'.');
		plot(log(f1),log(ds(:,3)),'.');
		plot(log(f1),log(ds(:,4)),'.');
		plot(log(f1),log(ds(:,5)),'.');
		plot(log(f1),log(ds(:,6)),'.');
	end
	
	fs1 = [];
	fs2 = [];
	slopes = nan(8,numlines);
	for speed_bin = [1:6]
	
		if numlines ==2
			this_se = errors(:,speed_bin);
			fs1 = find( this_se == min(this_se));
			fs1 = log(f1(fs1));
		elseif numlines == 3
			this_se = errors(:,:,speed_bin);
			[fs1 fs2] = find( this_se == min(min(this_se)) );
			fs1 = log(f1(fs1));
			fs2 = log(f1(fs2));
		end
		
		% we have the split points, now fit to them again
		[t1,t2,fit1,fit2,fit3] = fit_straight_lines(log(f1)',log(ds(:,speed_bin)),numlines,fs1,fs2,do_plot);
		
		
		slopes(speed_bin,1) = fit1.a;
		if numlines  > 1
			slopes(speed_bin,2) = fit2.a;
		end
		if numlines > 2
			slopes(speed_bin,3) = fit3.a;
		end
	end
	
	slopes(7,:) = mean(slopes(1:6,:));
	slopes(8,:) = median(slopes(1:6,:));
	%slopenames = {'slope1','slope2','slope3'};
	%T = array2table(slopes,'VariableNames',slopenames,'RowNames',{'bin1','bin2','bin3','bin4','bin5','bin6','mean','med'})
	%T = array2table(slopes,'RowNames',{'bin1','bin2','bin3','bin4','bin5','bin6','mean','med'})
	
	
	%f = figure('Position',[)
	%set(h,'Position',[10 10 50 50]);
	T = uitable(h,'Data',slopes,'Position',[80 50 210 145],'FontSize',6,'RowStriping','on','ColumnName',[],'ColumnWidth',{50 50 50},'RowName',{'bin1','bin2','bin3','bin4','bin5','bin6','mean','med'})
	usetitle = sprintf('16-04-28 %s midnight %dfits %d %s',station,numlines,coord,error_type);
	%writetable(T,sprintf('data/%s.txt',usetitle),'Delimiter',' ','WriteRowNames',true);
	
	if do_plot
		title(sprintf('%s coord %d, fitted by %s ',station,coord,error_type));
		saveas(h,sprintf('%s.pdf',usetitle));
	end
	
end