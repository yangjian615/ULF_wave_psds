
function [cmap] = make_cmap_lowest_white( )
% gets the current colormap and makes the very first value white
% also hands it back
	
	cmap = colormap;
	cmap(1,:) = [1 1 1];
	colormap(cmap);
end
