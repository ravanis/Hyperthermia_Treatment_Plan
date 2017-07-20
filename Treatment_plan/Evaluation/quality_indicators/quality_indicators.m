function quality_indicators(modelType, freq)
% Returns quality indicators HTQ, TC25/50/75, SARmaxTum, PLDmean
% The PLD must be saved in Results>P_and_unscaled_settings
% and be called P_modelType_freqMHz.mat
% modelType is a string eg. 'duke_nasal', 'duke_tongue_salt', 'child'
% freq is a number or a vector

% Get paths
filename = which('quality_indicators');
[evalpath,~,~] = fileparts(filename);
resultpath = [evalpath filesep '..' filesep '..' filesep 'MAIN' filesep 'Results'];
datapath = [resultpath filesep '..' filesep 'Data'];
ppath = [resultpath filesep 'P_and_unscaled_settings'];
addpath(resultpath, ppath)

% Load matrices
if length(freq)==1
    PLD = Yggdrasil.Utils.load([resultpath filesep 'P_and_unscaled_settings' filesep 'P_' modelType '_' num2str(freq) ...
        'MHz.mat']);
elseif length(freq)>1
    freqstr = num2str(freq);
    PLD = Yggdrasil.Utils.load([resultpath filesep 'P_and_unscaled_settings' filesep 'P_' modelType '_' regexprep(freqstr,'[^\w'']','') 'MHz.mat']);
end

tissue_mat = Yggdrasil.Utils.load([datapath filesep 'tissue_mat_' modelType '.mat']);

% Get Q.I.
[HTQ, PLDmaxTum, TC]=getHTQ(tissue_mat, PLD, modelType);
sizeOfPLD = size(PLD);
PLDmean = sum(PLD(:))/(sizeOfPLD(1)*sizeOfPLD(2)*sizeOfPLD(3));

disp(['HTQ is ' num2str(HTQ)])
disp(['TC is 25:' num2str(TC(1)) ', 50:' num2str(TC(2)) ',75:' num2str(TC(3))])
disp(['Maximum PLD in tumor is ' num2str(PLDmaxTum) ' W'])
disp(['Mean PLD in model is ' num2str(PLDmean) ' W'])
end