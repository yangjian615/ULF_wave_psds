% Code is designed to be sent off.
%
% Fit either two or one straight lines (logged) median power data. Split at all possible points: find the minimum split points by brute force, runnning over all combinations. 
% Results are saved but not plotted - call plot_three_split_all

function [] = do_line_split_all()
    
	% change as appropriate
    ddir = '/net/glusterfs_phd/scenario/users/mm840338/data_tester/data/';%strcat(pwd,sprintf('/data/'));
    stations = {'ISLL','GILL','FCHU','PINA'};
    y = [1990:2004];
    m = [1:12];
    of = 'speed';
    pop = 'ps';
	coord = 1;
	numlines = 2;
    
	for stcount = [1:length(stations)]
		station = stations{stcount};
		[meds,bins] = get_psd_medians(ddir,station,y,m,of,pop);
		
		freqs = [0:359]*1e3*(1/(720*5));
		f1 = freqs(freqs > 0.9 & freqs <=15);
		
		for coord = [1:2]
			if numlines ==2 
				se = nan(length(f1),6);
			elseif numlines == 3
				se = nan(length(f1),length(f1),6);
			end
			rse= se;
			
			for speed_bin = [1:6]
				d1 = meds(freqs>0.9 & freqs <= 15,coord,4,speed_bin);
				for sc1 = [3:length(f1)-3]
					if numlines == 2
						disp(sprintf('doing index %d for speed bin %d,station %s',sc1,speed_bin,station));
						[tse trse] = fit_straight_lines(log(f1)',log(d1),numlines,log(f1(sc1)),[],false);
						se(sc1,speed_bin)=tse;
						rse(sc1,speed_bin)=trse;
					elseif numlines ==3
						for sc2 = [3:length(f1)-3]
							if abs(sc1 -sc2) > 2 & sc2 > sc1 %only need to do each one once!
								disp(sprintf('doing indices %d,%d for speed bin %d,station %s',sc1,sc2,speed_bin,station));
								[tse trse] = fit_straight_lines(log(f1)',log(d1),numlines,log(f1(sc1)),log(f1(sc2)),false);
								se(sc1,sc2,speed_bin) = tse;
								rse(sc1,sc2,speed_bin) = trse;
								%disp(sprintf('sse %f rmse %f',tse,trse));
							end
						end
					end
				end
			end
			
			f_to_save = strcat(ddir,sprintf('all_midnight_%dfits_%s_%d',numlines,station,coord));
			save(f_to_save,'se','rse');
		end
    end
end