


    function [output,removed] = remove_by_threshold( input, z_low, z_high )
            % This is a simple threshold function that removes data too big or small
            % It checks Z values and whole field values.
            % It expects a whole slice, 720 rows, unknown no. of columns
            %It currentlty replaces out-of-threshold data with a row of
            %zeros but can return to just removing rows if necessry
            output = input;
            removed = zeros(size(input));

            input_size = size(input);
            z_col = input_size(2);
            y_col = input_size(2) - 1;
            x_col = input_size(2) - 2;
            
            % Andy suggested 50000 and 65000 as limits
            % My main thresholds were 5.95e4 and 6.2e4 for total and z
%             z_low = 5.8e4;
%             z_high = 6.4e4;

			%% remove according to z-value
            % dels = input(:, z_col) > z_high | input(:,z_col) < z_low;
            % output(dels,:) = zeros(sum(dels),input_size(2));
            % removed(dels,:) = input(dels,:);
            

			% remove according to total of x,y,z values
            tot_low = z_low;%5.95e4;
            tot_high = z_high;%6.3e4;
            tot_field = sqrt( output(:,x_col).^2 + output(:,y_col).^2 + output(:,z_col).^2 );

            dels = tot_field > tot_high | tot_field < tot_low;
            output(dels,:) = zeros(sum(dels),input_size(2));
            removed(dels,:) = input(dels,:);
            

    end
