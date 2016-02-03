% Simple function that plots the specified hour and x, y or z value.
% You get two plots: the raw data and the absolute value of the FFT.

% It's assumed the relevant file STATION_YEAR_MONTH has been loaded in and
% is called "data"

function [] = plot_one_hour( data, hour, index )
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
    
    to_plot = abs(fft( data(:,col,hour) - mean(data(:,col,hour)) ));
    
    title(sprintf('Raw data and absolute spectral decomposition of data from direction %s hour %d of given data',index,hour));
    
    subplot(1,2,1);
    plot((5/60)*n(1:N),data(:,col,hour));
    xlabel('Time (mins)');
    ylabel('Amplitude (nT)');
    grid on;
    axis([-inf,inf,-inf,inf]);
    
    plot_end = (720/2)+1;
    freqs = (fs/N)*n; 
    subplot(1,2,2);
    semilogy(freqs(2:plot_end), to_plot(2:plot_end)); %don't bother plotting zero (mean)
    xlabel('Frequency (Hz)');
    ylabel('Amplitude');
    grid on;
    
    line([1e-3,1e-3],get(gca, 'ylim'),'Color',[.8 .4 .4]);
    line([1e-2,1e-2],get(gca, 'ylim'),'Color',[.8 .4 .4]);
    %axis([1e-3,1e-2,-inf,inf]);
end
    
