% Input:
% data_dir
% station
% years
% months
% field - string corresponding to field of omni data, eg 'speed'
% coord - character, 'x', 'y' or 'z'
% sample_freq - required freq in milli Hz

function [] = PSD_field_scatterplot( data_dir, station, years, months, o_field, coord, sample_freq )
	
	disp(sprintf('Scatter plot for data at freq %f mHz',sample_freq));
	figure();
	% load in required data
	[all_data,data_bins] = get_all_psd_data(data_dir,station,years,months);
	
	N = length( cell2mat({all_data(1).x}) );
	n = [0:N/2-1];
	
	time_temp = all_data(1).times;
	time1 = time_temp(1);
	time2 = time_temp(2);
	
	t_res = abs(etime(datevec(time1),datevec(time2))); % in seconds

	f_res = 1/(N*t_res);
	freqs = f_res*n*1e3; %in mHz
	
	
	if sum( freqs == sample_freq ) ~= 1
		error('>>> No frequency match!!! <<<');
	end
	
	vals = cell2mat({all_data.(sprintf('%spsds',coord))});
	vals = vals(freqs == sample_freq, :);
	
	power_lims = [1e-5,1e11];%[0.7,1.5e5];
	ok_vals = (vals >= power_lims(1)) & (vals < power_lims(2));
	
	badvalinds = find(~ok_vals);
	if sum(~ok_vals) > 0
		for k = [1:sum(~ok_vals)]
			disp(sprintf('Outlier at %s',char(datetime(datevec(cell2mat({all_data(badvalinds(k)).dates}))))'));
		end
	end
	
	%subplot(2,1,1);
	sc_col = [7 144 203] ./ 255;
	scatter(cell2mat({all_data.(o_field)}),vals,7,sc_col,'.'); hold on;
	set(gca,'xscale','log');
	set(gca,'yscale','log');
	%axis_lim = [min(cell2mat({all_data.(o_field)}))-10,max(cell2mat({all_data.(o_field)}))+10,min(vals)-10,max(vals)+10];
	axis_lim = [min(cell2mat({all_data.(o_field)}))-20,max(cell2mat({all_data.(o_field)}))+20, 0.9e0,5e10];
	axis(axis_lim);
	%disp(axis_lim);
	xlabel(sprintf('Solar wind %s, km s^{-1}',o_field));
	ax.XTickLabelRotation=45;
	ylabel('Power, (nT)^2 mHz^{-1}');
	%title(sprintf('Scatter plot of data at frequency %f mHz',sample_freq));

	% subplot(3,1,2);
	% scatter(vals(ok_vals),cell2mat({all_data(ok_vals).(o_field)}),'.'); hold on;
	% %histogram(cell2mat({all_data.(o_field)}),'Orientation','horizontal','FaceAlpha',0.5);
	% ylabel(sprintf('%s',o_field));
	% xlabel('Power ??? UNIT');
	% title(sprintf('Scatter plot of data at frequency %f mHz, main region',sample_freq));
	
	% subplot(2,1,2);
	% histogram(log10(cell2mat({all_data.(o_field)})),'FaceAlpha',0.5); %'Orientation','horizontal'
	% hold on;
	% title('Just the speed histogram');
	% xlabel(sprintf('%s, km s^{-1}',o_field));
	% ylabel('Count');
	
	[meds,means]=getstuffscatter(all_data);
	meds = meds(freqs == sample_freq,:);
	means = means( freqs == sample_freq,:);
	
	col1 = [227 96 1] ./ 255;
	col2 = [169 52 137] ./ 255;%[155 95 176] ./ 255;;
	
	lwidth = 0.5;
	% plot medians for bins
	h1 = plot([min(cell2mat({all_data.speed})) cell2mat(data_bins.speed(1))],[meds(1) meds(1)],'LineWidth', lwidth,'color',col1);
	plot([cell2mat(data_bins.speed(1)) cell2mat(data_bins.speed(2))],[meds(2) meds(2)],'LineWidth', lwidth,'color',col1);
	plot([cell2mat(data_bins.speed(2)) cell2mat(data_bins.speed(3))],[meds(3) meds(3)],'LineWidth', lwidth,'color',col1);
	plot([cell2mat(data_bins.speed(3)) cell2mat(data_bins.speed(4))],[meds(4) meds(4)],'LineWidth', lwidth,'color',col1);
	plot([cell2mat(data_bins.speed(4)) cell2mat(data_bins.speed(5))],[meds(5) meds(5)],'LineWidth', lwidth,'color',col1);
	plot([cell2mat(data_bins.speed(5)) max(cell2mat({all_data.speed}))],[meds(6) meds(6)],'LineWidth', lwidth,'color',col1);
	
	% join up the steps
	plot([cell2mat(data_bins.speed(1)) cell2mat(data_bins.speed(1))],[meds(1) meds(2)],'LineWidth', lwidth,'color',col1);
	plot([cell2mat(data_bins.speed(2)) cell2mat(data_bins.speed(2))],[meds(2) meds(3)],'LineWidth', lwidth,'color',col1);
	plot([cell2mat(data_bins.speed(3)) cell2mat(data_bins.speed(3))],[meds(3) meds(4)],'LineWidth', lwidth,'color',col1);
	plot([cell2mat(data_bins.speed(4)) cell2mat(data_bins.speed(4))],[meds(4) meds(5)],'LineWidth', lwidth,'color',col1);
	plot([cell2mat(data_bins.speed(5)) cell2mat(data_bins.speed(5))],[meds(5) meds(6)],'LineWidth', lwidth,'color',col1);
	
	
	%plot means for bins
	h2 = plot([min(cell2mat({all_data.speed})) cell2mat(data_bins.speed(1))],[means(1) means(1)],'LineWidth', lwidth,'color',col2);
	plot([cell2mat(data_bins.speed(1)) cell2mat(data_bins.speed(2))],[means(2) means(2)],'LineWidth', lwidth,'color',col2);
	plot([cell2mat(data_bins.speed(2)) cell2mat(data_bins.speed(3))],[means(3) means(3)],'LineWidth', lwidth,'color',col2);
	plot([cell2mat(data_bins.speed(3)) cell2mat(data_bins.speed(4))],[means(4) means(4)],'LineWidth', lwidth,'color',col2);
	plot([cell2mat(data_bins.speed(4)) cell2mat(data_bins.speed(5))],[means(5) means(5)],'LineWidth', lwidth,'color',col2);
	plot([cell2mat(data_bins.speed(5)) max(cell2mat({all_data.speed}))],[means(6) means(6)],'LineWidth', lwidth,'color',col2);
	
	% join up the steps
	plot([cell2mat(data_bins.speed(1)) cell2mat(data_bins.speed(1))],[means(1) means(2)],'LineWidth', lwidth,'color',col2);
	plot([cell2mat(data_bins.speed(2)) cell2mat(data_bins.speed(2))],[means(2) means(3)],'LineWidth', lwidth,'color',col2);
	plot([cell2mat(data_bins.speed(3)) cell2mat(data_bins.speed(3))],[means(3) means(4)],'LineWidth', lwidth,'color',col2);
	plot([cell2mat(data_bins.speed(4)) cell2mat(data_bins.speed(4))],[means(4) means(5)],'LineWidth', lwidth,'color',col2);
	plot([cell2mat(data_bins.speed(5)) cell2mat(data_bins.speed(5))],[means(5) means(6)],'LineWidth', lwidth,'color',col2);
	
	legend([h1,h2],'medians','means','Location','southeast');

end