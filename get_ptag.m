
function pval = get_ptag()
	
	global ptag
	pval = ptag;

	if isempty(pval)
		fprintf('Tracing value ptag is unset; use default value 2.\n');
		pval = 2;
	end
	
end
	