% Simple function that plots the specified hour and x, y or z value.
% You get two plots: the raw data and the PSD calculated as in the paper.

% It's assumed the relevant file STATION_YEAR_MONTH has been loaded in and
% is called "data"

% Output is the calulated PSDs

function output = plot_one_hour_psd( data, hour, index, many )
    col = 0;

    if strcmp(index,'x')
        col = 8;
    elseif strcmp(index,'y')
        col = 9;
    elseif strcmp(index,'z')
        col = 10;
    else
        disp('Could not see which data is wanted!');
    end
    
    % initialise stuff
    ts = 5; %5s between samples
    fs = 1/ts; 
    N = 720; %no. samples in each slice (an hour)
    n = [0:N];
    
    %get relevant PSD
    window = 0.5*( 1 - cos(2*pi*n / (N-1)) );
    window = window(1:N);
    de_mean = data(:,col,hour) - mean(data(:,col,hour));
    psd = (2/(fs*sum(window)^2))*( (abs(fft( de_mean.*window' ))).^2 );
    
    
    
    subplot(1,2,1);
    plot(n(1:N)*5/60,data(:,col,hour));
    xlabel('Time (mins)');
    ylabel('Amplitude (nT)');
    grid on;
    %axis([0,N,-inf,inf]);
    
    if many
        hold on;
    end
    
    ymin = -inf;
    ymax = inf;
    plot_end = (N/2)+1;
    freqs = (fs/N)*n; 
    subplot(1,2,2);
    semilogy( freqs(1:plot_end), psd(1:plot_end));
    xlabel('Frequency (Hz)');
    ylabel('PSD');
    grid on;
    axis([1e-3,1e-2,ymin,ymax]);
    line([1e-3,1e-3],get(gca, 'ylim'),'Color',[.8 .4 .4]);
    line([1e-2,1e-2],get(gca, 'ylim'),'Color',[.8 .4 .4]);
    
    %# vertical line
%     hx = graph2d.constantline(0, 'LineStyle',':', 'Color',[.7 .7 .7]);
%     changedependvar(hx,'x');
    
    
    
    if many
        hold on;
    end
    
    output = psd;
    
end
    
