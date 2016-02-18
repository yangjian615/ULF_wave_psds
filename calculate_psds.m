% HISTORY
% 15-12-09 Totally rewritten (begun)
% 16-02-03 Save data in slightly different folder

% Does the calculations for each month, then saves the PSD and omni data
% away. "As_IDL" is an option that scales the final product by 1/N^2, as
% the fourier transforms are s.t. FT_M = 1/N *FT_I

%WORKING 
% I don't think the equation for W is right. You should probably divide by
% N instead

function [] = calculate_psds( data_dir, station, years, months, F_res, as_idl, use_window)

    load(strcat(data_dir,sprintf('%s_omni',station)));
    omni_all = omni_data;
    omni_size = size(omni_data);

    %xyz_means = find_overall_mean(data_dir,station,years,months);

    % make the windowing function
    N = 720;
    n = [0:N-1];
    w = 0.5*(1-cos(2*pi*n/(N-1)));
    
    % FIX WHICH TO USE
    %W = sum(w.^2);
    W = N*sum(w.^2); % this one for change attempt

    
    for year = years
        for month = months
            f_to_load = strcat(data_dir,sprintf('/ready/%s_%d_%d',station,year,month));
            f_to_save = strcat(data_dir, sprintf('/psds/%s_%d_%d',station,year,month));
            load(f_to_load);
            
            disp(sprintf('calculating psds for %s, year %f month %f',station,year,month));
            
            % remove unnecessary rows
            data(:,1:7,:) = [];
            
            %subtract the mean and apply window
            data_size = size(data);
            for hour = [1:data_size(3)]
                for index = [1:data_size(2)]
                    data(:,index,hour) = data(:,index,hour) - mean(data(:,index,hour)); %use mean of that column
                    %data(:,index,hour) = data(:,index,hour)-xyz_means(index);
                    if use_window
                        data(:,index,hour) = data(:,index,hour) .* w';
                    end
                end
            end
            
            
            % calculate FFT and PSD
            data_ft = fft(data,[],1);
            data_ft(((N/2)+1):N,:,:) = [];
            hr_psds = (2/(F_res))*(abs(data_ft)).^2;
            
            if as_idl
                hr_psds = (1/N^2)*hr_psds;
            end
            if use_window
                hr_psds = (1/W)*hr_psds;
            end
            
            
            save(f_to_save,'hr_psds','mini_omni');
            
            
            
        end
    end

end