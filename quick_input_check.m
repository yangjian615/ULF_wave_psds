% Quick check on teh raw data. Are any of these empyt?

%Histopry
% 16-02-03 CReated


function [] = quick_input_check()

    years = [1990:2004];
    months = [1:12];
    data_dir = strcat(pwd,'/data/');

    for year = years
        for month = months
            fbame = strcat(data_dir,sprintf('/raw/GILL_%d_%d',year,month));
            load(fbame);
            if sum(sum(data)) == 0
                disp(fbame)
            end
        end
end