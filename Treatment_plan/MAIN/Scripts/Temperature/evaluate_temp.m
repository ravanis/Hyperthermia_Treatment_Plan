function [temp_mat, tx] = evaluate_temp(modelType, freq, overwriteOutput)
%function [temp_mat] = EVALUATE_TEMP(overwriteOutput)
%   Reads the output from example 3(FEniCS temp. simulations)
%   and transforms it into a .mat file. It also ends with some evaluation
%   of the temperature, such as T90, T70, T50.

if nargin < 3
    overwriteOutput = false;
end

% Get all paths
filename = which('evaluate_temp');
[temperaturepath,~,~] = fileparts(filename);
datapath = [temperaturepath filesep '..' filesep '..' filesep 'Data'];
scriptpath = [temperaturepath filesep '..'];
resultpath = [temperaturepath filesep '..' filesep '..' filesep 'Results' filesep 'T_and_final_settings'];
temppath = [temperaturepath filesep '..' filesep '..' filesep 'Results' filesep 'FEniCS_results' filesep modelType ...
    filesep 'temperature.h5'];
addpath(scriptpath)

% Ensure Extrapolation package is available
% It is needed to load .mat-files
if strcmp(which('Extrapolation.load'), '')
    error('Need addpath to the self-developed package ''Extrapolation''.')
end

% Load all tissues
tissue_mat = Extrapolation.load([datapath filesep 'tissue_mat_' modelType '.mat']);
[a,b,c] = size(tissue_mat);

% Skip transforming the temperature if .mat already exists
if ~exist([resultpath filesep 'temp_' modelType '_' num2str(freq) 'MHz.mat'], 'file') || overwriteOutput || length(freq)>1
    
    % Transform FEniCS-format to .mat
    disp('Transforming temperature format, will take some time.')
    temp_mat = read_temperature(temppath,1,1,1,a,b,c);
    
    % Save temperature
    mat = temp_mat;

    if length(freq)==1
        save([resultpath filesep 'temp_' modelType '_' num2str(freq) 'MHz.mat'], 'mat', '-v7.3');
    elseif length(freq)>1
        save([resultpath filesep 'temp_' modelType '_1_' num2str(freq(1)) '_2_' num2str(freq(2)) 'MHz.mat'], 'mat', '-v7.3');
    end
else % If the .mat file already exists
    disp('Using previously calcuated temperature .mat file.')
    temp_mat = Extrapolation.load([resultpath filesep 'temp_' modelType '_' num2str(freq) 'MHz.mat']);
end

% Evaluate tumor temp
[tx] = tumor_temp(temp_mat, modelType, freq);
end