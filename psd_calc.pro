;this is what i am using
;window length in minutes
;psd in nt^2/Hz

function psd_calc, xin, han_win=han_win, res=res

if keyword_set(han_win) then begin
	data_window = hanning(n_elements(xin))
	data_corr=2.67038
endif else begin
	data_window = dblarr(n_elements(xin))
	data_window[*]=1.0
	data_corr = 1.0
endelse

if keyword_set(res) then res=res else res=1.0

if n_elements(xin) lt 2 then begin
	print,"guess again!"
	xin = cos(findgen(512))
endif
	                xwin = xin*data_window
                    xfft = FFT(xwin)
                    xpsd = abs(xfft[0:n_elements(xfft)/2])
                    xpsd = xpsd*xpsd*2*data_corr
                    xpsd = xpsd/(1./(n_elements(xin)*res))

xfreq = findgen(n_elements(xpsd))
xfreq = xfreq*(1./(n_elements(xin)*res)) ; frequency axis in Hz

psd = {freq: xfreq, psd: xpsd}
		return,psd
end
