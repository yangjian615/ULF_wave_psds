% Finds however many equally spaced frequencies in range you want 
% Pass in however many you want and the list of freqs

function [f_slices] = get_sample_freqs(numfreqs, freqs, f_lim);
	
	f_lo = f_lim(1);
	f_hi = f_lim(2);
	
	f_slices = quantile(linspace(f_lo,f_hi,100),numfreqs);

	% find closest in list
	for sl_count = [1:length(f_slices)]
		closest_val = min(abs(freqs - f_slices(sl_count)));
		closest_ind = find( abs(freqs - f_slices(sl_count)) == closest_val) ;
		f_slices(sl_count) = freqs(closest_ind);
	end
	
end