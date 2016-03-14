% input must be N x index x num_slices. N is number of data points

function [hr_psds] = calculate_psds( data )
	data_size = size(data);
		
	N = data_size(1);
    n = [0:N-1];
    w = 0.5*(1-cos(2*pi*n/(N-1)));
    W = sum(w.^2)/N;

	if length(data_size) == 2
		data_size(3) = 1;
	end
	%xyz_means = find_overall_mean(data_dir,station,years,months);
	
	for slice = [1:data_size(3)]
		for index = [1:data_size(2)]
			data(:,index,slice) = data(:,index,slice) - mean(data(:,index,slice)); %use mean of that column
			%data(:,index,slice) = data(:,index,slice)-xyz_means(index);
			data(:,index,slice) = data(:,index,slice) .* w';
		end
	end
	
	% calculate FFT and PSD
	data_ft = fft(data,[],1);
	data_ft(((N/2)+1):N,:,:) = [];
	hr_psds = (2/(N*W))*(abs(data_ft)).^2;


end