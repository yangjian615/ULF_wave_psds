% Plots medians for different sectors of the omni field requested in gen_opts.

function [all_meds] = plot_medians( data, gen_opts, num_quants, t_res )

	% you have a function rescale_power that does this now but in this case what's here is quicker
	% so I left t.
	change_units = false;%true;%false; % if true we use (nT)^2 /mHz instead fo /Hz)
	rescale = false; % if true then the area under curve should equal


	if isempty(gen_opts)
		gen_opts = make_basic_struct('gen_opts');
	else 
		check_basic_struct(gen_opts,'gen_opts');
	end
	
	coord = gen_opts.coord;
	o_f = gen_opts.of;
	f_lim = gen_opts.f_lim;
	power_lims = gen_opts.pop_lim;
	o_f_lims = gen_opts.of_lim;
	
	%f_res = 1/( length(data(1).x) * t_res);
	%freqs = (data(1).freqs)*1e3;
	freqs = data(1).freqs;
	
	% get f_res from freqs instead
	f_res = abs(freqs(1)-freqs(2));
	
	axis_lim = [0.9,15,-inf,inf];%0.5e-3,0.5e7];

		
	power = cell2mat({data.(sprintf('%s%s',coord,'ps'))});
	omni_vals = cell2mat({data.(o_f)});
	
	all_meds = nan(length(freqs),num_quants+1);
	if num_quants > 1
		[quants,in_which_sector] = sort_by_speed_sectors(omni_vals,num_quants);
		
		leg_tab = {};
		for r_count = 1:num_quants+1
			
			%figure(1);
			in_this_sector = in_which_sector ==r_count;
			these_meds = median(power(:,in_this_sector),2);
			
			
			if rescale
				these_meds = these_meds / (f_res);
			end
			if change_units
				these_meds = these_meds*1e-3;
			end
			
			all_meds(:,r_count) = these_meds;
			
			plot(freqs,these_meds,'-x'); hold on;
			%leg_tab{r_count} = 'blah';
		end
		
		
		
		
		legend_title = ofield_axis_label(o_f);

		legend_labels = {};
		legend_labels{1} = strcat('<',num2str(quants(1)));
		for k = [1:length(quants)-1]
			legend_labels{k+1} = strcat(num2str(quants(k)),' - ',num2str(quants(k+1)));
		end
		legend_labels{length(quants)+1} = strcat('> ',num2str(quants(end)));			
		%legend(leg_tab);
		l = legend(legend_labels);
		%title(l,legend_title)
		
	else
		use_meds = median(power,2);
		
		if rescale
			use_meds = use_meds / (f_res);
		end
		if change_units
			use_meds = use_meds*1e-3;
		end
		
		plot(freqs,use_meds,'-x'); hold on;
	end
	
	%axis(axis_lim);
	set(gca,'yscale','log');
	xlabel('Freq, mHz');
	if change_units
		ylabel('PSD, (nT)^2 / mHz');
	else
		ylabel('PSD, (nT)^2 / Hz');
	end
	
	
	
	%omni_vals = cell2mat({data.(o_f)});
	
	%ok_vals = (power >= power_lims(1)) & (power < power_lims(2)) ...
	%	& (omni_vals >= o_f_lims(1)) & (omni_vals <= o_f_lims(2));
	
end



