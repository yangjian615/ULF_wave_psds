

function [output_data] = rescale_power(data)
% rescale the power, changing units to (nT)^2 / mHz and the freqs to mHz


	ptag = get_ptag();
	do_print(ptag,2,'rescale_power:entering function\n');
	
	
	N = size(cell2mat({data(1).x}),1);

	output_data = data;
	coords = {'x','y','z'};
	p_length = size(cell2mat({data(1).xps}),1);
	for c_count = 1:length(coords)
		coord = coords{c_count};
	
		all_power = cell2mat({data.(sprintf('%sps',coord))});
		all_power = all_power*1e-3;

		data_to_add = mat2cell(all_power,p_length,ones(1,length(data))); 
		[output_data(:).(sprintf('%sps',coord))] = data_to_add{:};
	end
			
			
	% and make sure freqs match power		
	do_print(ptag,3,'rescale_power: rescaling freqs to (nT)^2 / mHz \n');
	freqs = output_data(1).freqs*1e3; %now in mHz
	
	for t_count = 1:length(output_data)
		output_data(t_count).freqs = freqs;
	end
			
end
	