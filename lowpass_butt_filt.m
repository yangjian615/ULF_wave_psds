% Makes butterworth filter to prevent aliasing.
% This is more than enough filetring since we are only interested in 0-15 mHz
% More analysis needed really
% We assume x is detrended here

function [b,a] = lowpass_butt_filt( )
	
	Wp = 60/100; %cutoff freq pass corner (40 mHz)(recall normalised to 1)
	Ws = 90/100; %cutoff freq stop corner
	
	Rp = 3; %3dB passband ripple
	Rs = 30; %30dB stopband attenuation
	%These amounts picked by looking at pmtm(x,4,length(x),f_sam) output. 
	
	[n,Wn] = buttord(Wp,Ws,Rp,Rs);
	[b,a] = butter(n,Wn);
	
	%x_filt = filter(b,a,x);
	
end