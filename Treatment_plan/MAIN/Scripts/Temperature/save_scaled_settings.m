function save_scaled_settings(modelType,freq,nbrEfields)
% This function saves the new settings after the temperature loop in FEniCS
% has found a good scale. 

%find file paths
filename = which('save_scaled_settings');
[temperaturepath,~,~] = fileparts(filename);
resultpath = [temperaturepath filesep '..' filesep '..' filesep 'Results' filesep]; 
settingpath = [resultpath 'P_and_unscaled_settings'];
savepath = [resultpath 'T_and_final_settings'];
amppath = [resultpath 'FEniCS_results' filesep modelType filesep 'scaledAmplitudes.txt'];
addpath(temperaturepath,settingpath)

% Find phase and amplitude from their respective files and create new
% settings vector 
if length(freq)==1
    settingsID = fopen([settingpath filesep 'settings_' modelType '_' num2str(freq) 'MHz.txt']);
    ampID = fopen(amppath);
    for i = 1:nbrEfields
        if i==1
            for j=1:2
                fscanf(settingsID,'%s',1);
            end
        end
        fscanf(settingsID,'%s',1);
        amp_cell{i}=fscanf(ampID,'%s',1);
        fas_cell{i}=fscanf(settingsID,'%s',1);
    end
    fas = zeros(nbrEfields,1);
    amp = fas;
    for k = 1:nbrEfields
        fas(k) = str2num(fas_cell{k});
        amp(k) = str2num(amp_cell{k});
    end
end
settings = [amp fas];

%Use writeSettings to create new settings file 
writepath = [temperaturepath '..'];
addpath(writepath)
writeSettings(savepath,settings,modelType,freq)
end
