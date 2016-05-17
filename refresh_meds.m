% Recalculates all medians

function [] = refresh_meds()
	
	stations = {'GILL','FCHU','ISLL','PINA'};
	ddir = '/net/glusterfs_phd/scenario/users/mm840338/data_tester/data/';
	y = [1990:2004];
	m = [1:12];
	of = 'speed';
	pop = 'ps';
	
	for scount = [1:length(stations)]
		station = stations{scount};
		
		[meds,bins] = get_psd_medians(ddir,station,y,m,of,pop);
		
		f_to_save = strcat(ddir,sprintf('%s_medians_%s_%s',station,of,pop));
		save(f_to_save,'meds','bins');
	
	end
	
end