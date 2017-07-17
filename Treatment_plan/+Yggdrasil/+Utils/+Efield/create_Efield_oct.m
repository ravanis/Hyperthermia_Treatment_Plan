function create_Efield_oct( Efield_file_name, sigma_file_name, rel_eps1, rel_eps2)
%CREATE_EFIELD_OCT( Efield_file_name, sigma_file_name)
%   From a given signle frequency Efield .mat file, weights and 
%   save an octree version of of the E-field. The weight is 
%   \sqrt(sigma) and is used to simplify calculations 
%   of power density.
%INPUT:
%   Efield_file_name - The filename of the .mat file to be octreed and
%      weighted. The filename should not include the .mat part.
%   sigma_file_name - The filename for the sigma (conductivity) file.
%      If the file is a .mat it will be resaved as _sqrt.oct as this
%      simplifies futher calculations
%   rel_eps1, rel_eps2 are optional arguments setting the relative error of
%       approximation during octree creation. If only rel_eps1 is given
%       both E-field and Sigma will be approximated using rel_eps1.
%       If both rel_eps1 and rel_eps2 is given, 1 will be used for E-fields
%       and 2 will be used for Sigma.
    narginchk(2,4);
    if ~exist([sigma_file_name '_sqrt.oct'],'file')
        if exist('rel_eps2','var')
            Yggdrasil.Utils.Efield.create_sigma_oct(sigma_file_name, rel_eps2);
        elseif exist('rel_eps1','var')
            Yggdrasil.Utils.Efield.create_sigma_oct(sigma_file_name, rel_eps1);
        else
            Yggdrasil.Utils.Efield.create_sigma_oct(sigma_file_name);
        end
    end

    sigma_sqrt_oct = Yggdrasil.Utils.load(...
                        [sigma_file_name '_sqrt.oct']);
    disp(['Weights and converts ' Efield_file_name...
        ' to octree format, might take some time.'])
    if exist('rel_eps1','var')
        E_field_oct = Yggdrasil.Octree(...
           Yggdrasil.Utils.load([Efield_file_name '.mat']),...
           'rel_eps', rel_eps1);
    else
        E_field_oct = Yggdrasil.Octree(...
            Yggdrasil.Utils.load([Efield_file_name '.mat']));
    end
    
    Yggdrasil.Utils.Efield.save_Efield_oct(...
        E_field_oct, sigma_sqrt_oct, Efield_file_name);
    disp('Done!')
end

