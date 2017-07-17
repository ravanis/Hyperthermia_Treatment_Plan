function  create_sigma_mat(freq, modelType)
%CREATE_SIGMA_MAT(freq, modelType)

if exist(get_path('sigma', modelType, freq),'file')
    disp('Sigma already exists, delete to create new.')
    return;
end

filename = which('create_sigma_mat');
[optpath,~,~] = fileparts(filename);
datapath = [optpath filesep '..' filesep '..' filesep 'Data' filesep];
addpath(optpath)

if startsWith(modelType, 'duke')==1
    parampath = [datapath 'df_duke_neck_cst_' num2str(freq) 'MHz.txt'];
elseif strcmp(modelType, 'child')
    parampath = [datapath 'df_chHead_cst_' num2str(freq) 'MHz.txt'];
else
    error('Model type not available. Enter the full name of your model tissue_file in create_sigma_mat.')
end

tissue_mat = Yggdrasil.Utils.load([datapath...
    'tissue_mat_' modelType '.mat']);

% Read the first file and save the wanted collums
paramMat = caseread(parampath);
paramMat(end-1:end,:)= []; % Removes the last two rows

% Creates two columns containing index and sigma values
[~, index, ~, ~, sigma, ~] = strread(paramMat', '%s %d %f %d %f %f',...
    'whitespace', '\t');
% Convert sigma to sigma_mat, corresponding to tissue_mat
index_to_row = zeros(max(index),1);
index_to_row(index) = 1:length(index);
sigma_mat = sigma(index_to_row(tissue_mat));

% Remove conductivity of non-biological data
if startsWith(modelType, 'duke') == 1
    water_ind = 81;
    ext_air_ind = 1;
    int_air_ind = 2;
elseif strcmp(modelType, 'child')
    water_ind = 30;
    ext_air_ind = 1;
    int_air_ind = 5;
else
    error('Model type not available. Enter your model indices in create_sigma_mat.')
end

sigma_mat(tissue_mat == water_ind) = 0;
sigma_mat(tissue_mat == ext_air_ind) = 0;
sigma_mat(tissue_mat == int_air_ind) = 0;

save([datapath 'sigma_' modelType '_' num2str(freq) 'MHz.mat'], 'sigma_mat', '-v7.3');
end