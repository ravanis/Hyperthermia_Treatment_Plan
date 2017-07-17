function quality_indicators(modelType, freq)
% Returns quality indicators HTQ, TC25, SARmaxTum

addpath Example\1_Efield_example\Scripts\       
addpath Example\2_Prep_FEniCS_example\Scripts\  

% Get paths
filename = which('quality_indicators');
[evalpath,~,~] = fileparts(filename);
rootpath = [evalpath filesep '..' filesep '..' filesep 'Example'];
datapath = [rootpath filesep '1_Efield_example' filesep 'Data'];

% Load matrices
if nargin == 2
    if length(freq)==1
PLD = Yggdrasil.Utils.load([rootpath filesep '1_Efield_results_adv' filesep 'P_' modelType '_' num2str(freq) ...
    'MHz.mat']);
    elseif length(freq)>1
        PLD = Yggdrasil.Utils.load([rootpath filesep '1_Efield_results_adv' filesep 'P_' modelType '_1_' num2str(freq(1)) ...
    '_2_' num2str(freq(2)) 'MHz.mat']);
    end
else
    [freq_comb_filename]= find_freq_comb(modelType, freq, 'P');
    PLD = Yggdrasil.Utils.load([rootpath filesep '1_Efield_results_adv' filesep freq_comb_filename]);
end
tissue_mat = Yggdrasil.Utils.load([datapath filesep 'tissue_mat_' modelType '.mat']);

% Get Q.I.
addpath Evaluation\quality_indicators
[HTQ, PLDmaxTum, TC]=getHTQ(tissue_mat, PLD, modelType);

disp(['HTQ is ' num2str(HTQ)])
disp(['TC is 25:' num2str(TC(1)) ', 50:' num2str(TC(2)) ',75:' num2str(TC(3))])
disp(['Maximum PLD in tumor is ' num2str(PLDmaxTum) ' W'])
end
