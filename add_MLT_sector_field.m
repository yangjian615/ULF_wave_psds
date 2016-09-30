

function [output] = add_MLT_sector_field( data )
	
	ptag = get_ptag();
	do_print(ptag,2,'add_MLT_sector_field: entering function \n');
	
	day_ranges = [3,9;9,15;15,21;21,3];
	
	all_dates = cell2mat({data.dates});
	all_dates = datevec(all_dates);
	all_hours = all_dates(:,4);
	
	sector_list = sort_by_sectors(all_hours,day_ranges);
	sector_list = num2cell(sector_list);
	
	output = data;
	[output.MLT_sector] = sector_list{:};
	
	
end