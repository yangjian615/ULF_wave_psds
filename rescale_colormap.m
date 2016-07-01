% Rescales a given colormap based on quantiles of the data rather than some weird linear thing MATLAB does.
% Data should be fed in as 1d. We will use ascending order.

% It finds quantiles of the data and maps so that each colour in the colormap corresponds to a quantile; each 
% colour change then corresponds to the same quantity of data. I have written up the maths if you want more detail.

% This is particularly suitable for histograms and intensity maps where "data" is the count

function [new_cmap] = rescale_colormap( old_cmap, data )
	
	warning('>> DOESNT SEEM TO WORK <<');
	if sum(isnan(data)) > 0
		error('>> NaNs found <<');
	end
	data = sort(data); 
	quants = quantile(data,62);
	%sdisp(quants);
	
	% get a curve interpolated for all three colour directions
	int1 = fit([1:64]',old_cmap(:,1),'cubicinterp');
	int2 = fit([1:64]',old_cmap(:,2),'cubicinterp');
	int3 = fit([1:64]',old_cmap(:,3),'cubicinterp');
	
	new_cmap = old_cmap;
	
	% get rescaled interior colours
	temp = [1:64];
	for col_ind = [2:63]
		q = quants(col_ind-1); %the quantile value for this point
		d_pt = median(find(data==q));%index location of this point
		if isnan(d_pt) %ie nothing had this value, must find closest
			closest = abs(data-q);
			d_pt = median(find(closest==min(closest)));
			if isnan(d_pt)
				error('>>>couldnt find index of quantile<<<');
			end
		end
		rescaled_pt = (d_pt/length(data))*64; % rescaling from index along data to [1:64] axis
		temp(col_ind) = rescaled_pt;
		new_cmap(col_ind,:) = [int1(rescaled_pt) int2(rescaled_pt) int3(rescaled_pt)];
	end
	
	% check your new colourmap
	if sum(sum(new_cmap>1)) > 0 | sum(sum(new_cmap<0)) > 1
		error('>>>rescaled colormap is no good<<<');
	end
	
	%figure(11); 
	%subplot(3,1,1); rgbplot(old_cmap); axis([1,64,0,1]);
	%subplot(3,1,2); rgbplot(new_cmap); axis([1,64,0,1]);
	%subplot(3,1,3); plot([1:64],[1:64],'k'); hold on; plot([1:64],temp,'--r');
	


end

%log map workaround from internet for scaling colorbar to match ? (I think)
% % D is your data

% % Rescale data 1-64

% d = log10(D);

% mn = min(d(:));

% rng = max(d(:))-mn;

% d = 1+63*(d-mn)/rng; % Self scale data

% image(d);

% hC = colorbar;

% L = [0.01 0.02 0.05 0.1 0.2 0.5 1 2 5 10 20 50 100 200 500 1000 2000 5000];

% % Choose appropriate

% % or somehow auto generate colorbar labels

% l = 1+63*(log10(L)-mn)/rng; % Tick mark positions

% set(hC,'Ytick',l,'YTicklabel',L);
