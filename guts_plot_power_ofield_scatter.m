% Plots the intensity map of teh omni field data and the power

function [output] = guts_plot_power_ofield_scatter( fn_st )
	
	output = [];
	
	fignum = fn_st.sector;
	figure(fignum);
	subplot(fn_st.pl_rows,fn_st.pl_cols,fn_st.f_count);
	scatter(fn_st.xs,fn_st.ys,7,'filled');
	
	set(gca,'yscale','log');
	ylabel('Power');
	xlabel(fn_st.gen_opts.of);
	
	
end