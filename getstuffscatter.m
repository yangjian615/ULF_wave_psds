% gets the medians, means necessary for Clare's scatterplot. Warning: done quickly only!

function [meds,means] = getstuffscatter(all_data)
	warning('>>> Only quick writing here, shoddy for later!<<<');
	data_dir = strcat(pwd,'/data/');
	station = 'GILL';
	years = [1990:2004];
	months = [1:12];

	%[all_data,data_bins] = get_all_psd_data(data_dir,station,years,months);

	meds = [];
	means = [];

	the_xpsds = cell2mat({all_data.xpsds});
	the_speed_bins = cell2mat({all_data.speed_bin});
	for speedbin = [1:6]
		this_bin = the_speed_bins == speedbin;
		meds(:,speedbin) = median(cell2mat({all_data(this_bin).xpsds}),2);
		means(:,speedbin) = mean(cell2mat({all_data(this_bin).xpsds}),2);
	end
end