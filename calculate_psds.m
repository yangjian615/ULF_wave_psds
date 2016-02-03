% HISTORY
% 15-12-09 Totally rewritten (begun)
% 16-02-03 Save data in slightly different folder

% Does the calculations for each month, then saves the PSD and omni data
% away.

%WORKING 
% I don't think the equation for W is right. You should probably divide by
% N instead

function [] = calculate_psds( data_dir, station, years, months, Fs)
    
    load(strcat(data_dir,sprintf('%s_omni',station)));
    omni_all = omni_data;
    omni_size = size(omni_data);


    % make the windowing function
    N = 720;
    n = [0:N-1];
    w = 0.5*(1-cos(2*pi*n/(N-1)));
    W = N*sum(w.^2);
    
    % FIX WHICH TO USE
    W = sum(w.^2);
    
    
    for year = years
        for month = months
            f_to_load = strcat(data_dir,sprintf('/ready/%s_%d_%d',station,year,month));
            f_to_save = strcat(data_dir, sprintf('/psds/%s_%d_%d',station,year,month));
            load(f_to_load);
            
            disp(sprintf('calculating psds for %s, year %f month %f',station,year,month));
            
            % remove unnecessary rows
            data(:,1:7,:) = [];
            
            %subtract the mean
            data_size = size(data);
            for hour = [1:data_size(3)]
                for index = [1:data_size(2)]
                    data(:,index,hour) = data(:,index,hour) - mean(data(:,index,hour));
                end
            end
                
            
            % calculate FFT and PSD
            data_ft = fft(data,[],1);
            data_ft(((N/2)+1):N,:,:) = [];
            hr_psds = (Fs/(N*W))*2*(abs(data_ft)).^2;
            
            
            save(f_to_save,'hr_psds','mini_omni');
            
            
            
        end
    end

end