% This function reads in the data and sorts it by hour - it returns the
% data with an extra dimension which is hour (this information is left in
% the matrices, so that the first column in every "slice" should contain
% the same hour with different time)

% We do it month by month.

%HISTORY
%16-01-04 Run even if results file already exists. Still check loading file
%OK.
%16-02-03 Save and load data from slightly different place


function [] = sort_by_hour( data_dir, station, years, months  )
    disp('Sorting by hour');
	
	max_month_size = (31*24+7)*60*60/5;
	basis = ones(max_month_size,1);
	s = [0:max_month_size-1]'*5; %have to have every second not every five for mismatches when resetting data
    month_basis = horzcat(basis,basis,basis,basis,0*basis,s);
	basis_m = month_basis;
    
    for year = years
        for month = months
            %tic
            f_to_load = strcat(data_dir,sprintf('/thresholded/%s_%d_%d',station,year,month));
            f_to_save = strcat(data_dir,sprintf('/sorted1/%s_%d_%d',station,year,month));
            
            
%             if exist(strcat(f_to_save,'.mat')) == 2
%                 disp('Skipping month - processing already done as file exists');
%             elseif exist(strcat(f_to_load,'.mat')) ~= 2
%                 disp('Skipping month - previous processing level not found');
%             else
            if  exist(strcat(f_to_load,'.mat')) == 2 %& exist(strcat(f_to_save,'.mat')) ~= 2 
                word_temp = sprintf('sort_by_hour: Doing year %d, month %d',year, month);
                disp(word_temp);
                load(f_to_load); %now using matrix 'data'


                data_size = size(data);
				sorted_data = nan(data_size(1)+max_month_size,10);
				basis_m = month_basis;
				basis_m(:,1) = data(1,2)*basis_m(:,1); %year
				basis_m(:,2) = data(1,3)*basis_m(:,2); %month
				basis_m(:,3) = data(1,4)*basis_m(:,3); %day
				basis_m(:,4) = data(1,5)*basis_m(:,4); %hour
				
				
				sorted_data(1:data_size(1),:) = data;
				sorted_data(data_size(1)+1:max_month_size+data_size(1),1) = datenum(basis_m);
				sorted_data = sortrows(sorted_data,1);
				
				% keep unique ones
				[unique_dates,unique_date_indices] = unique(sorted_data(:,1));
				sorted_data = sorted_data(unique_date_indices,:);
				
				
				% put into slices shape
				sorted_data = reshape(sorted_data,720,[],10);
				sorted_data = permute(sorted_data,[1 3 2]);
				
				bad_data = sum(sum(isnan(sorted_data),2));
				data = sorted_data(:,:, bad_data < 720*9 ); %remove any fully bad slices
				bad_data = sum(sum(isnan(data),2));
				bad_data(1) = 0; %keep first and last slices anyway
				bad_data(length(bad_data)) = 0;
				data(:,:,bad_data > 0) = [];
				
				% replace end-hour nans with zeros in preparation for fix_moved_hours
				data_size = size(data);
				bad_data = isnan(data(:,2,1)); %this should really check across whole row not just one value
				temp = data(~bad_data,:,1); 
				temp_size = size(temp);
				data(:,:,1) = zeros(720,10);
				data(1:temp_size(1),:,1) = temp;	
				
				bad_data = isnan(data(:,2,data_size(3)));
				temp = data(~bad_data,:,data_size(3));
				temp_size = size(temp);
				data(:,:,data_size(3)) = zeros(720,10);
				data(1:temp_size(1),:,data_size(3)) = temp;

                % for hour = [1:max_hrs]

                    % if min(data_size) > 0        
                        % top_lim = 720;

                        % if top_lim > data_size(1)
                            % top_lim = data_size(1);
                        % end
                        % %disp(data(1,5));

                        % this_hour = data(1:top_lim,5) == data(1,5);
                        % hour_data = data(this_hour,:);
                        % temp_data(1:sum(this_hour),:,hour) = hour_data;
                        % data(this_hour,:) = [];
                        % data_size = size(data);
                    % end
                % end

                % if min(size(data)) > 0
                    % disp('Not all data used!');
                % end

                % debug_data = data;

                % data = temp_data;
                % empty_slices = sum(sum(data(:,:,:))) == 0;
                % data(:,:,empty_slices) = [];

                save(f_to_save,'data');
                %toc
            end
        end
    end
end
                    
           

