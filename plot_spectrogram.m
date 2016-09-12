% still uses windows of same length for spectrogram, althought htey may end up starting in differen tplasce
% ebing a bit naughty and using it for CWT plot too. 

function [cwtS1] = plot_spectrogram( data, gen_opts, win_mins, t_res, plot_type )

	if isempty(gen_opts)
		gen_opts = make_basic_struct('gen_opts');
	else 
		check_basic_struct(gen_opts,'gen_opts');
	end 
	
	if  ~isstruct(data)
		error('plot_spectrogram:BadInputType','expected a struct holding data');
	end
	
	coord = gen_opts.coord;
	o_f_lims = gen_opts.of_lim;
	
	
	% make gappy matrix, hand back indices that were OK and nans for others
	dates = cell2mat({data.dates});
	%win_secs = min(abs(etime(datevec(dates(1:end-1)),datevec(dates(2:end))))); % this would take ages
	win_secs = win_mins*60;
	indices = [1:length(dates)];
	
	to_fill = [dates', indices'];
	
	if size(to_fill,2) ~=2
		error('plot_spectrogram:BadMatrix','not the size or shape you expected');
	end
	
	filled = make_gappy_matrix_by_date( to_fill, win_secs );
	
	% get all data in cell first: one row for each window, either the data for that coord or lots of nans
	N = length(cell2mat({data(1).x}));
	empties = {nan*[1:N]'};

	
	
	coord_vals_cell = {};
	
	for d_count = 1:length(filled)
		this_ind = filled(d_count,2);
		
		if isnan(this_ind)
			coord_vals_cell(d_count) = empties;
		else
			coord_vals_cell(d_count) = {data(this_ind).(coord)};
		end
	end

	filled_data = struct('dates',num2cell(filled(:,1)),'coord_vals',coord_vals_cell');
	
	all_data = cell2mat({filled_data.coord_vals});
	all_data = reshape(all_data,1,[]); % doing it this long way round as I'm sure the order is right. You could speed this up.
	
	if strcmp(plot_type,'STFT')
		spectrogram(all_data,hann(N),[],N,1/t_res,'yaxis')  %windows using hanning window, length of fft N, overlap 50% if popssible (this is empty field)
		axis([-inf,inf,0,15]);
	elseif strcmp(plot_type,'CWT')
		%NOTE mostly written from matlab examples, not finished wavelet reading
		
		% convert scale to freq
		%s = ; %scale
		% dt = t_res / 1e3; % need time (sampling intervl) in milliseconds
		
		% numOctave = 8; %???
		% numVoices = 16; % ???
		
		% s0 = 2;
		% a0 = 2^(1/numVoices);
		% scales = s0*a0.^(0:numOctave*numVoices);
		% fprintf('plot_spectrogram: Number of octaves is %1.3f\n',max(log2(scales))-min(log2(scales)));	  
		
		% % you can use helperCWTTimeFreqVectorto get log spaced scale vectror for CWT from min and max freq
		% % DO NOT UNDEERSTAND THIS CODE YET
		% f0 = 5/(2*pi); %centre of wavelet?
		% t = 0:dt:(numel(all_data)-1)*dt;
		
		
		% minfreq = 0.5*1e-3;%in cycles/unit time
		% maxfreq = 100*1e-3; % in cycles/unit time
		% scales = helperCWTTimeFreqVector(minfreq,maxfreq,f0,dt,32); %min desired freq, max desired freq,sampling interval,voices per octave
		%this_cwt = cwtft({all_data,dt},'wavelet','bump','scales',scales);
		%helperCWTTimeFreqPlot(this_cwt.cfs,t./60,this_cwt.frequencies*1e3,'surf','CWT using bump wavelet','Hours','mHz');
		sig = struct('val',all_data,'period',t_res);
		t = [0:length(all_data)-1]*t_res; %in seconds here
		%cwtft({all_data,t_res},'plot');
		
	
		cwtS1 = cwtft(sig,'plot','Wavelet','bump');
		
		scales = cwtS1.scales; 
		
		%if sampling period units are in seconds the frequencies cwtS1.frequencies are in Hz
		%Bt this code doesn't use the freqs!
		%MorletFourierFactor = 4*pi/(6+sqrt(2+6^2));
		%cfreq = 1./(scales.*MorletFourierFactor);
		cfreq = cwtS1.frequencies;
		
		flim_to_plot = [1,15]*1e-3; %mHz limits
		plot_vals = cfreq >= flim_to_plot(1) & cfreq <= flim_to_plot(2);
		
		
		figure(2);
		x_axis = t/(60*60); x_lab = 'Hours';
		y_axis = cfreq(plot_vals)*1e3; y_lab = 'Pseudofreq, mHz';
		z_axis = abs(cwtS1.cfs);%real(cwtS1.cfs); 
		z_axis = z_axis(plot_vals,:); %z_axis = z_axis./(sum(sum(abs(z_axis)))); %weird bad normalisation to fiddle with colormap
		
		% make more into zeroes for simplicity
		%w_tol = 10e-2 ; % wavelet zero tolernace
		%z_axis( abs(z_axis) < w_tol ) = 0;
		%z_axis = abs(z_axis);
		
		axis_lim = [-inf,inf,flim_to_plot(1)*1e3,flim_to_plot(2)*1e3];
		
		contour(x_axis,y_axis,z_axis);
		xlabel(x_lab);
		ylabel(y_lab);
		axis(axis_lim);
		
		
		% and plot the 3d surf bit
		
		
		figure(3);
		h = pcolor(x_axis,y_axis,z_axis);
		
		%colormap(parula);
		%cmap = rescale_colormap(colormap,n_flat);
		%disp('rescaling');
		cmap = colormap;
		%cmap(1,:) = [1 1 1]; % if you take out any they should be zero coefficients, which may not be the first
		colormap(cmap);
		%shading flat;
		shading interp
		xlabel(x_lab);
		ylabel(y_lab);
		axis(axis_lim);
	else
		error('plot_spectrogram:BadOption','you need to specify STFT orCWT');
	end
		
	
end
	
	
	
	
