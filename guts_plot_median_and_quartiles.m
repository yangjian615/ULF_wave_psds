% Takes in a data and plots the median and upper/ lower quartiles for th coordinate of psd data

function [output] = guts_plot_median_and_quartiles( fn_st )
	output = [];

	
	ptag = get_ptag();
	do_print(ptag,2,'guts_plot_median_and_quartiles: entering function\n');
	
	
	data = fn_st.data;
	%fig_num = fn_st.hf;
	selection_data = fn_st.selections;
	coord = fn_st.extras.coord;
	sscount = fn_st.scount;

	ps = cell2mat({data.(sprintf('%sps',coord'))});
	freqs = cell2mat({data(1).freqs})*1e3;
	
	quants = quantile(ps',3);
	
	% check size is as expected
	if size(quants,1) ~=  3 | size(quants,2) ~= length(data(1).xps)
		error('plot_median_and_quantiles:BadSize','unexpected matrix size for quantile output');
	end
	
	low_q = quants(1,:);
	med_q = quants(2,:);
	upp_q = quants(3,:);
	
	%disp(fig_num);
	%figure(fig_num);
	%figure();
	%subplot(7,1,sscount);
	plot(freqs,med_q); hold on;
	%plot(freqs,low_q,'--r');
	%plot(freqs,upp_q,'--r');

	% plot them all to show 
	%for temp_count = 1:length(data)
	%	plot(freqs,ps(:,temp_count));
	%end


	xlabel('Freq, mHz');
	ylabel('PSD, (nT)^2 / mHz');
	set(gca,'yscale','log');
	axis([1,15,0,10e5]);
	%title(sprintf('options set %d',fn_st.scount)); %really I want to display the selection data
	
end

% Actually what I think I want to do is the normalised power intesnity slice plotts with x axis freq and y aixs psd for the given data.

% THIS ISNT WORKING. EVERYTHING COMES OUT HTE SAME AND TITLE IS "3"

	
	
