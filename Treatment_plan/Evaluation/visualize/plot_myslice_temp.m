function plot_myslice_temp(scale, modelType, freq)

% Get temp_path
filename = which('marathon');
[rootpath,~,~] = fileparts(filename);
if length(freq)==1
temp_path = ([rootpath filesep '4_Temperature_results' filesep 'temp_' modelType '_' num2str(freq) 'MHz.mat']);
elseif length(freq)>1
temp_path = ([rootpath filesep '4_Temperature_results' filesep 'temp_'  modelType '_1_' num2str(freq(1)) '_2_' num2str(freq(2)) 'MHz.mat']);
end

% Load temp_mat
temp_mat = Extrapolation.load(temp_path);

% Plot
myslicer(scale*temp_mat/(max(temp_mat(:))))
end