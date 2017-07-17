function save_sigma_oct( sigma_oct, file_name )
%SAVE_SIGMA_OCT( sigma_oct, file_name )
%   Saves a octree of conductivity in its most the practical form,
%   that is the sqrt of the conductivity.
%INPUT:
%   sigma_oct - An octree containing the conductivity parameter
%   file_name - A string of the file name. This string should not contain
%      any file endings as this will be automatically added.
    
    % Use sqrt on sigma to get paramater used to weight the Efields with
    sigma_oct = sigma_oct.^0.5;
    save([file_name '_sqrt.oct'], 'sigma_oct', '-v7.3');
end

