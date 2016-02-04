% Find xyz means of all 'ready' datafor station and years

function [xyz_means] = find_overall_mean(data_dir,station,years,months)
    all_data = zeros(1,3,0);

    %load in all relevant data
    for year = years
        for month = months
            load(strcat(data_dir,sprintf('ready/%s_%d_%d.mat',station,year,month)));
            disp(sprintf('Loading data for %s, year %d month %d to find mean',station, year, month)); 

            all_data = cat(3,all_data,mean(data(:,8:10,:)));
        end
    end
    
    xyz_means = mean(all_data,3);


end