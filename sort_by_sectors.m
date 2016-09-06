%simple function to sort whether the hours are in each part of the day.


function in_the_sectors = sort_by_sectors( hour_list, day_ranges )
% expect a column vector of the list hours. Put out a matrix, one column for each sector of day
	sector_sizes = size(day_ranges);
	%in_the_sectors = false( length(hour_list),sector_sizes(1) );
	
	in_the_sectors = nan(1,length(hour_list));

	
	for sector = [1:sector_sizes(1)]
		%disp(sprintf('Sector %f and speed %f',sector,speed));
		hr_range = day_ranges(sector,1:2);

		if hr_range(2) > hr_range(1)
			%in_the_sectors(:,sector) = ( hour_list >= hr_range(1)) & ( hour_list < hr_range(2));
			in_this_one = ( hour_list >= hr_range(1)) & ( hour_list < hr_range(2));
		else
			%in_the_sectors(:,sector) = ( (hour_list >= hr_range(1)) & ( hour_list < 24) )  | ( (hour_list >= 0) & (hour_list < hr_range(2)) );
			in_this_one = ( (hour_list >= hr_range(1)) & ( hour_list < 24) )  | ( (hour_list >= 0) & (hour_list < hr_range(2)) );
		end
		in_the_sectors(in_this_one) = sector;
	end
end