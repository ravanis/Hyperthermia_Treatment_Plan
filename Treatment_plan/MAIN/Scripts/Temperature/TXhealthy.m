function [ tx_h ] = TXhealthy( X, temp_mat, tissue_mat, modelType, freq)
%   Finds the X percentile of temperature in healthy tissue.

filename = which('TXhealthy');
[temppath,~,~] = fileparts(filename);
datapath = [temppath filesep '..' filesep '..' filesep 'Data' filesep];

% Defines tumor index for model
if startsWith(modelType, 'duke')
    tumor_ind=80;
elseif startsWith(modeltype,'child')
    tumor_ind=9;
else
    error('Modeltype not defined in TXhealthy.m, see Scripts>Temperature.')
end

tx_h=TX(X, temp_mat, tissue_mat, tumor_ind, 1);
end