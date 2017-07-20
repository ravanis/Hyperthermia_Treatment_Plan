function quality_indicators(modelType, freq)
% Returns quality indicators HTQ, TC25, SARmaxTum

% Get paths
filename = which('quality_indicators');
[evalpath,~,~] = fileparts(filename);
resultpath = [evalpath filesep '..' filesep '..' filesep 'MAIN' filesep 'Results'];
datapath = [resultpath filesep '..' filesep 'Data'];
ppath = [resultpath filesep 'P_and_unscaled_settings'];
addpath(resultpath, ppath)

% Load matrices
if nargin == 2
    if length(freq)==1
PLD = Yggdrasil.Utils.load([resultpath filesep 'P_and_unscaled_settings' filesep 'P_' modelType '_' num2str(freq) ...
    'MHz.mat']);
    elseif length(freq)>1
        PLD = Yggdrasil.Utils.load([resultpath filesep 'P_and_unscaled_settings' filesep 'P_' modelType '_1_' num2str(freq(1)) ...
    '_2_' num2str(freq(2)) 'MHz.mat']);
    end
% else
%     [freq_comb_filename]= find_freq_comb(modelType, freq, 'P');
%     PLD = Yggdrasil.Utils.load([resultpath filesep 'P_and_unscaled_settings' filesep freq_comb_filename]);
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