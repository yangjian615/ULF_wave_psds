

function [out_str] = ofield_axis_label( ofield )
% returns string for axis label including units.
	out_str = [];
	
	if strcmp(ofield,'speed')
		out_str = 'Solar wind speed, km s^{-1}';
	elseif strcmp(ofield,'Np')
		out_str = 'Proton number density, #N cm^{-3}';
	elseif strcmp(ofield,'Bz');
		out_str = ('Bz, (nT)');
	elseif strcmp(ofield,'vxBz')
		out_str = 'Coupling function v_x B_z, mV m^{-1}';
	elseif strcmp(ofield,'sigma_v')
		out_str = 'Solar wind speed variation, km s^{-1}';
	else
		error('>> No axis label for this omni data field <<');
	end
end