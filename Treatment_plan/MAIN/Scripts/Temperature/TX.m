function [ tx ] = TX( X, temp_mat, tissue_mat, indeces_of_interest, healthy)
%[ tx ] = TX( temp_mat, tissue_mat, ignore_index )
% Finds the X percentile of temperature.

% Pick out the temperatures in the volume of interest
max_ind = max(tissue_mat(:));

if nargin ==4
    vol_index = false(1,max_ind);
    vol_index(indeces_of_interest) = true;
elseif nargin ==5
    vol_index = true(1,max_ind);
    vol_index(indeces_of_interest) = false;
end
temps = temp_mat(vol_index(tissue_mat));

% Get the percentile
temps = sort(temps);
tx = temps(ceil(length(temps)*(1-X/100)));

end

