% data held in cell eg {d45,d60,d120}.
% interpolate and take the same 100 points out of 0-15mHz window for each.
% compares the medians calculated between window lengths where each set of data is a different window length

function [] = compare_medians(all_data,num_meds)

	all_meds = {};
	
	% get medians for each and store in cell
	for d_count = 1:length(all_data)
		each_data = all_data{d_count};

		
		figure();
		each_meds = plot_medians(each_data,[],num_meds-1); %empty gen_opts atm but you could specify so not speed
		
		all_meds{d_count} = num2cell(each_meds);
		
	end
	
	% get the 100 points for each
	the_100pts = linspace(0,15,100);
	all_pts = {};
	for d_count = 1:length(all_data)
		these_meds = cell2mat(all_meds{d_count});
		
		
		each_data = all_data{d_count};
		freqs = 1e3*each_data(1).freqs;
		
		these_100 = nan(100,num_meds);
		for q_count = 1:num_meds
			sector_meds = these_meds(:,q_count);
			
			% interpolate to get a single curve
			int = fit(freqs,sector_meds,'cubicinterp');
			these_100(:,q_count) = int(the_100pts);
			
		end
		all_pts{d_count} = num2cell(these_100);
	end
	
	% now what do you want to do with them? Variance, mean?
	
	% if two enterd find absolute difference
	if length(all_data) == 2

		int_pts1 = cell2mat(all_pts{1});
				
		int_pts2 = cell2mat(all_pts{2});
	
		abs_diff = abs( int_pts1 - int_pts2);
		
		figure();
		for q_count = 1:num_meds
			plot(the_100pts,abs_diff(:,q_count)); hold on;
		end
		
		xlabel('Freq, mHz');
		ylabel('Absolute difference between median PSD estimates');
		
	end
	
end
			
			
			
		
		