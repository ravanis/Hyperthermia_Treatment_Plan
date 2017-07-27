function [tx] = tumor_temp(temp_mat, modelType, freq)
%function [tx] = tumor_temp(temp_mat)
%   Makes an evaluation of the temperature in the tumor
%   using the T90, T70, T50, T0 indicators.

% Used during evaluation
if startsWith(modelType, 'duke')
    tumor_ind = 80;
elseif startsWith(modelType,'child')
    tumor_ind = 9;
else
    error('Model type not available. Enter your model indices in tumor_temp.')
end

% Get all paths
filename = which('tumor_temp');
[rootpath,~,~] = fileparts(filename);
datapath = [rootpath filesep '..' filesep '..' filesep 'Data'];
mypath = [rootpath filesep '..' filesep '..' filesep '..' filesep 'Libs' filesep 'myslicer'];
addpath(mypath)

% Ensure Extrapolation package is available
% It is needed to load .mat-files
if strcmp(which('Extrapolation.load'), '')
    error('Need addpath to the self-developed package ''Extrapolation''.')
end

% Load all tissues
tissue_mat = Extrapolation.load([datapath filesep 'tissue_mat_' modelType '.mat']);

% Find percentiles
tx = TX([0 10 50 90]', temp_mat, tissue_mat, tumor_ind);
disp('Tumor temperatures are:')
fprintf('Tmax %f,\nT10 %f,\nT50 %f,\nT90 %f\n',tx(1),tx(2),tx(3),tx(4));
tx_h = TXhealthy([0 10 50 90]', temp_mat, tissue_mat, modelType, freq);
disp('Temperatures in healthy tissue are:')
fprintf('Tmax %f,\nT10 %f\nT50 %f,\nT90 %f\n', tx_h(1),tx_h(2),tx_h(3),tx_h(4));
sizeOfT = size(temp_mat);
Tmean = sum(temp_mat(:))/(sizeOfT(1)*sizeOfT(2)*sizeOfT(3));
disp(['Tmean for whole model is: ' num2str(Tmean)])

disp('Trying to plot the temperature using myslicer.')
if strcmp(which('myslicer'), '')
    disp('myslicer not found.')
else
    figure;
    myslicer(50*temp_mat/max(temp_mat(:)));
end
end