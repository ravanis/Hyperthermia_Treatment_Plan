function save_Efield_oct( E_field_oct, sigma_sqrt_oct, file_name)
%SAVE_EFIELD_OCT( Efield_file_name, sigma_file_name)
%   From a given SF_Efield.mat file, weights and save an octree
%   version of of the E-field. The weight is sqrt(sigma/2) and 
%   is used to simplify calculations of power densities.
%INPUT:
%   E_field_oct - An octree contianing a raw E_field (raw = non-weighted)
%   sigma_sqrt_oct - An octree containing the sqrt(conductivity)
%   file_name - A string containing the file_name of the saved file. This 
%      string should not contain a file ending as this will automatically
%      be added.
    
    E_field_oct = E_field_oct.weight(sigma_sqrt_oct)/sqrt(2);
    
    save([file_name '_weighted.oct'], 'E_field_oct', '-v7.3');
end

