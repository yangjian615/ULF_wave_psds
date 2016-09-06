% Plots the distribution of data by hour and day. Gaps indicate no data.
% The colours indicate a Z-value: this can be considered a plot of a scalar
% field on 2d data which is designed to include data gaps.
%
% Input should be three equal length columns; x-values, y-values and the
% scalar value at that xy point.
%
% We use minimum and maximum xy value to create a mesh, then fill in the
% appropriate grid points to forma  matrix Z of the scalar values. THis is plotted as a surface and viewed from the top. 
%
% Currently it expects dates on the x-axis
%
% An example call has xcol: datenums made from [y m d 0 0 0], ycol: vecotr of hours, zcol: sw speed

function [] = plot_data_spread(xcol,ycol,zcol,title_words)

    figure();
    [Y,X] = meshgrid( floor(min(ycol)):ceil(max(ycol)) , min(xcol):max(xcol) );
    Z = NaN(max(xcol)-min(xcol)+1,ceil(max(ycol))-floor(min(ycol))+1);
	
    %run through hrs, dys to put in real data
    for i =[1:length(ycol)]
        xval = xcol(i);
        yval = ycol(i);
        zval = zcol(i);

        location = X == xval & Y == yval;
        Z(location) = zval;
    end

	%disp(size(X)); disp(size(Y)); disp(size(Z));
    surf(X,Y,Z);
    view(2);
    shading flat;
    datetick('x',22);
    title(title_words);
    
end