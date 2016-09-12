% Changes scale of colorbar and makes labels match
% This is for the case where you have plotted the log of your data so need to make the Tiick show e^(data);


function [] = logscale_colorbar( colHandle )
	
	labels = colHandle.TickLabels; % get the cell
	new_labels = {};
	
	for l_count = 1:length(labels)
		new_lab = exp(str2num(labels{l_count}));
		new_labels{l_count} = num2str(new_lab,'%1.2e\n');
	end
	
	colHandle.TickLabels = new_labels;
end
	