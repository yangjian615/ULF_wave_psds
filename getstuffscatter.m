% gets the medians, means necessary for Clare's scatterplot. Warning: done quickly only!

function [meds,means] = getstuffscatter(all_data,coord,ps_or_psd)
	
	%[all_data,data_bins] = get_all_psd_data(data_dir,station,years,months);

	meds = [];
	means = [];

	what_checking = sprintf('%s%s',coord,ps_or_psd);
	the_speed_bins = cell2mat({all_data.speed_bin});
	for speedbin = [1:6]
		this_bin = the_speed_bins == speedbin;
		meds(:,speedbin) = median(cell2mat({all_data(this_bin).(what_checking)}),2);
		means(:,speedbin) = mean(cell2mat({all_data(this_bin).(what_checking)}),2);
	end
end