function quality_indicators(modelType, freq, x)
% Returns quality indicators HTQ, TC25, SARmaxTum

addpath Example\1_Efield_example\Scripts\       
addpath Example\2_Prep_FEniCS_example\Scripts\  

% Get paths
filename = which('quality_indicators');
[evalpath,~,~] = fileparts(filename);
rootpath = [evalpath filesep '..' filesep 'Example'];
datapath = [rootpath filesep '1_Efield_example' filesep 'Data'];

% Get rho
if length(freq) == 1
create_rho_mat(modelType, freq);
elseif length(freq)>1
    create_rho_mat(modelType, freq(1));
end

% Load matrices
PLD = Yggdrasil.Utils.load([rootpath filesep '1_Efield_results' filesep 'P_' modelType '_' num2str(freq) 'MHz.mat']);
tissue_mat = Yggdrasil.Utils.load([datapath filesep 'tissue_mat_' modelType '.mat']);
rho = Yggdrasil.Utils.load([datapath filesep 'rho_' modelType '.mat']);

% Calculate SAR
SARMatrix = PLD./rho;

% Get Q.I.
addpath Evaluation\qualInds
[HTQ, SARmaxTum, TC]=getHTQ(tissue_mat, SARMatrix, modelType,freq);

disp(['HTQ is ' num2str(HTQ)])
disp(['TC25 is ' num2str(TC(1))])
disp(['Maximum SAR in tumor is ' num2str(SARmaxTum) ' W'])
end
