% Match up windows of OMNI and CANOPUS data and allocate their values to a structure.

function [output_data] = remove_bad_omni( data, omni_data )

	ptag = get_ptag();

	do_print(ptag,2,sprintf('remove_bad_omni: entering function \n'));


	omni_dates = cell2mat({omni_data.dates});
	max_entries = size(data,3);
	data_dates = data(1,1,:);
	
	
	% get omni field names
	omni_fields = fieldnames(omni_data);
	
	% work out which hours match up to each other then put in (from new construction of omni data this may be unnecessary)
	entry = 1;
	omni_inds = nan(1,max_entries);
	data_inds = nan(1,max_entries);
	
	% if the hour is in both set up indices of matching
	for hr_ind = 1:max_entries
	
		this_hour = data_dates(hr_ind);
		matching = omni_dates == this_hour;
		
		if sum( matching ) == 1
			data_inds(entry) = hr_ind;
			omni_inds(entry) = find(matching);
			entry = entry+1;
		end
	end
	
	data_inds = data_inds(~isnan(data_inds));
	omni_inds = omni_inds(~isnan(omni_inds));
	
	d_size = length(data_inds);
	win_length = length(data(:,1,1)); %not calulcated properly here!
	
	
	%% Now put them in struct. Have to fiddle with mat2cell to add vectors to structs
	data_s = [];
	
	% 'dates', start time of window
	data_to_add = num2cell(data(1,1,data_inds)); 
	[data_s(1:d_size).dates] = data_to_add{:};
	
	% 'times'
	data_to_add = mat2cell(squeeze(data(:,1,data_inds)),win_length,ones(1,d_size)); 
	[data_s(1:d_size).times] = data_to_add{:};
	
	% 'x'
	data_to_add = mat2cell(squeeze(data(:,8,data_inds)),win_length,ones(1,d_size)); 
	[data_s(1:d_size).x] = data_to_add{:};
	
	% 'y'
	data_to_add = mat2cell(squeeze(data(:,9,data_inds)),win_length,ones(1,d_size)); 
	[data_s(1:d_size).y] = data_to_add{:};
	
	% 'z'
	data_to_add = mat2cell(squeeze(data(:,10,data_inds)),win_length,ones(1,d_size)); 
	[data_s(1:d_size).z] = data_to_add{:};
	
	
	% and the omni data - simpler as no vecotrs, just scalars
	for f_ind = 2:length(omni_fields)
		clear('data_to_add');
		omni_field = char(omni_fields(f_ind));
		data_to_add = num2cell(cell2mat({omni_data(omni_inds).(omni_field)}));
		[data_s(1:d_size).(omni_field)] = data_to_add{:};
	end
	
	
	if size(data_s,1) == 1 && isempty(data_s(1).dates)
		data_s = [];
	end


	output_data = data_s;


end
