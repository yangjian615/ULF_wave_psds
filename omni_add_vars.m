% Add the variations (and any other data) from high res to low_res

function [] = omni_add_vars(data_dir, data_opts, perc_ok,pars_to_get,pars_to_get_vars)

	ptag = get_ptag();
	do_print(ptag,2,'omni_add_vars: entering function \n');
	
	station = data_opts.station;
	years = data_opts.y;
	months = data_opts.m;
	win_mins = data_opts.win_mins;
	
	% load in low res omni data
	fomni_lr_to_load = strcat(data_dir,sprintf('omni_low_res/prepped/%s_omni_%d',station,win_mins));
	fomni_lr_to_save = strcat(data_dir,sprintf('omni_low_res/filled_in/%s_omni_%d',station,win_mins));
	
	load(fomni_lr_to_load);
	lr_omni = omni_data;
	window_dates = cell2mat({lr_omni.dates});
	window_dates = datevec(window_dates);
	
	
	win_begins = window_dates; win_begins(:,4) = win_begins(:,4) - 1; win_begins = datetime(win_begins);
	win_ends = datetime(window_dates);
	
	
	
	do_print(ptag,2,'omni_add_vars: using prepped not interpolated (fixed) omni_1min data \n');
	
	for year = years
		for month = months 
			% use prepped data and NOT fixed as this would include interpolation
			% you may want to change this
			fomni_to_load = strcat(data_dir,sprintf('/omni_1min/prepped/%s_omni_1min_%d_%d_%d',station,win_mins,year,month));
			
			
			do_print(ptag,2,sprintf('omni_add_vars: Getting requested high res data from %s %d %d\n',station, year,month));
			
			
			if exist(strcat(fomni_to_load,'.mat'),'file')

				% and get previous to load
				fprev_to_load = [];
				if month == 1
					fprev_to_load = strcat(data_dir,sprintf('/omni_1min/prepped/%s_omni_1min_%d_%d_%d',station,win_mins,year-1,12));
				else 
					fprev_to_load = strcat(data_dir,sprintf('/omni_1min/prepped/%s_omni_1min_%d_%d_%d',station,win_mins,year,month-1));
				end				
				
				
				load(fomni_to_load);
				curr_omni = omni_data;
				
				% now get across stuf that should be in this month
				if exist(strcat(fprev_to_load,'.mat'),'file')
					load(fprev_to_load);
					prev_dates = datevec(cell2mat({omni_data.dates}));
					in_month = prev_dates(:,2) == month;
					keep = omni_data(in_month);
					do_print(ptag,3,sprintf('Rescued %d data entries from wrong month\n',sum(in_month)));
					omni_data = [keep,curr_omni];
				end
				
				
				
				
				omni_out = [];
				omni_fields = fieldnames(omni_data);
				o_dates = cell2mat({omni_data.dates});
				o_datetimes = datetime(datevec(o_dates));
			
				bad = 0;
				good = 0;
				
				% get rough values of low res data
				this_lr = window_dates(:,1) == year & window_dates(:,2) == month;
				this_lr = find(this_lr);
				
				omni_index =0;
				do_print(ptag,3,'omni_add_vars: about to run over roughly close OMNI dates\n');
				for win_count = 1:length(this_lr) %[1:length(window_dates)]
				% Get stuf from up to an hour before the window.
					win_ind = this_lr(win_count);
					
					win_begin = win_begins(win_ind);
					win_end = win_ends(win_ind);
					
					in_win = isbetween(o_datetimes,win_begin,win_end);

					
					% add means of the OMNI data top structure if we have enough data points
					if sum(in_win) >= floor(perc_ok*win_mins)
						good = good+1;
						omni_index = omni_index+1; %so we know where to add info
						for o_count = [1:length(omni_fields)]
							
							o_field = char(omni_fields(o_count));
							
							if any(strcmp(pars_to_get,o_field)) % get this par
								do_print(ptag,4,sprintf('omni_add_vars: adding mean of par %s \n',o_field));
								lr_omni(win_ind).(o_field) = mean( cell2mat({omni_data(in_win).(o_field)}) );
							end
							
							% add variance if we want it
							if any(strcmp(pars_to_get_vars,o_field))
								do_print(ptag,4,sprintf('omni_add_vars: adding var of par %s \n',o_field));
								lr_omni(win_ind).(strcat('sigma_',o_field)) = var( cell2mat({omni_data(in_win).(o_field)}) );
							end	
								
							
						end
						
					else
						bad = bad+1;
					end
					do_print(ptag,4,sprintf('omni_add_vars: ratio %f of this window we had \n',(sum(in_win) / (win_mins))));
					
					
				end
				
				
				do_print(ptag,3,sprintf('omni_add_vars: %d good and %d bad windows here\n',good,bad));
			else
				do_print(ptag,2,'omni_add_vars: no file found to load\n');
			end
		end
	end

	% check them all: if they dont have a value then put in Nan
	for p_count = 1:length(pars_to_get)
		this_par = pars_to_get{p_count};
		do_print(ptag,3,sprintf('omni_add_vars: filling in gaps with Nans for %s \n',this_par));
		
		all_ps = {lr_omni.(this_par)};
		make_nans = find(cellfun(@isempty,all_ps));
		
		add_nans = num2cell(nan(1,length(make_nans)));
		[lr_omni(make_nans).(this_par)] = add_nans{:};
		
		% check 
		temp = {lr_omni.(this_par)};
		if length(temp) ~= length(lr_omni)
			error('fail');
		end
	end
	for pv_count = 1:length(pars_to_get_vars)
		this_var = strcat('sigma_',pars_to_get_vars{pv_count})
		do_print(ptag,3,sprintf('omni_add_vars: filling in gaps with Nans for %s \n',this_var));
		
		all_pvs = {lr_omni.(this_var)};
		all_pvs(1)
		make_nans = find(cellfun(@isempty,all_pvs));
		

		add_nans = num2cell(nan(1,length(make_nans)));
		[lr_omni(make_nans).(this_var)] = add_nans{:};
		
		% check 
		temp = {lr_omni.(this_var)};
		if length(temp) ~= length(lr_omni)
			error('fail');
		end
	end
	
	
	
	omni_data = lr_omni;
	save(fomni_lr_to_save,'omni_data');
	
end
		
		
	