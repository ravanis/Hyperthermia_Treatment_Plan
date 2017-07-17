function create_sigma_oct( sigma_file_name, rel_eps )
%CREATE_SIGMA_OCT( sigma_file_name )
%   Creates a octree version of a sigma .mat file.
%INPUT:
%   sigma_file_name - the filepath to the sigma .mat file. This string
%      should not contain the ".mat" part.
%   rel_eps is the relative approximation error (OPTIONAL)
    narginchk(1,2);
    
    disp(['Converting ' sigma_file_name...
        ' to octree format, might take some time.'])
    if nargin == 1
    sigma_oct = Yggdrasil.Octree(...
        Yggdrasil.Utils.load([sigma_file_name '.mat']));
    else
        sigma_oct = Yggdrasil.Octree(...
        Yggdrasil.Utils.load([sigma_file_name '.mat']),...
        'rel_eps', rel_eps);
    end
    Yggdrasil.Utils.Efield.save_sigma_oct(sigma_oct, sigma_file_name);
    disp('Done!')
end

