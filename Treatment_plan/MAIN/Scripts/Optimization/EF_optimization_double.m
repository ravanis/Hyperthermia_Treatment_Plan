function [] = EF_optimization_double(freq, nbrEfields, modelType)
%[P] = EF_OPTIMIZATION()
%   Calculates a optimization of E-fields to maximize power in tumor while
%   minimizing hotspots. The resulting power loss densities and antenna settings  will then be
%   saved to the results folder.

% Ensure Yggdrasil is available
if strcmp(which('Yggdrasil.Octree'), '')
    error('Need addpath to the self-developed package ''Yggdrasil''.')
end

% Get root path
filename = which('EF_optimization_double');
[rootpath,~,~] = fileparts(filename);
datapath = [rootpath filesep '..' filesep '..' filesep 'Data'];
scriptpath = [rootpath filesep '..'];
addpath(scriptpath)

% Initialize load_maestro to be able to load E_fields
Efilename = @(f,a)[datapath filesep 'Efield_' num2str(f) 'MHz_A' num2str(a) '_' modelType];
sigma     = @(f)[datapath filesep 'sigma_' modelType '_' num2str(f) 'MHz'];
rel_eps = 0.1;
Yggdrasil.Utils.Efield.load_maestro('init', Efilename, sigma, rel_eps);

frequencies = freq;
n = nbrEfields;
f_1 = frequencies(1);
f_2 = frequencies(2);

% Convert sigma from .txt to a volumetric matrix
for f = frequencies
    create_sigma_mat(f, modelType);
end

% Create Efield objects for two frequencies
e_f1 = cell(1,n);
e_f2 = cell(1,n);

for i = 1:n
    e_f1{i} = Yggdrasil.SF_Efield(f_1,i);
    e_f2{i} = Yggdrasil.SF_Efield(f_2,i);
end

% Load information of where tumor is, and healthy tissue
tissue_mat = Yggdrasil.Utils.load([datapath filesep 'tissue_mat_' modelType '.mat']);
if startsWith(modelType, 'duke')==1
    water_ind = 81;
    ext_air_ind = 1;
    int_air_ind = 2;
    tumor_ind = 80;
elseif modelType == 'child'
    water_ind = 30;
    ext_air_ind = 1;
    int_air_ind = 5;
    tumor_ind = 9;
end

healthy_tissue_mat = tissue_mat~=water_ind & ...
    tissue_mat~=ext_air_ind & ...
    tissue_mat~=tumor_ind & ...
    tissue_mat~=int_air_ind;

tumor_oct = Yggdrasil.Octree(single(tissue_mat==tumor_ind));
healthy_tissue_oct = Yggdrasil.Octree(single(healthy_tissue_mat));
tumor_mat = tissue_mat==tumor_ind;

e_tot = e_f1{1};
for i = 2:length(e_f1)
    e_tot = e_tot + e_f1{i};
end

disp('---PRE-OPTIMIZATION---')
% disp('AMPLITUDE - PHASE - ANTENNA')
% AntennaSettings = zeros(n,3);
% wave = e_tot.C.values;
% ant = e_tot.C.keys;
%
% for i=1:length(wave)
%     AntennaSettings(i,1) = abs(wave(i));
%     AntennaSettings(i,2) = 0; %It is 0 otherwise, but technically its 45
% end
% AntennaSettings = [AntennaSettings(:,1) AntennaSettings(:,2) ant']

p_tot = abs_sq(e_tot);

disp(strcat('Pre-optimization, HTQ= ',num2str(HTQ(p_tot,tumor_mat,healthy_tissue_mat))))

%Optimization step 1: optimization of M1 at the first frequency
disp('Figure shows M1-values, not HTQ.')
[X, E_opt] = OptimizeM1(e_f1,tumor_oct,healthy_tissue_oct,nbrEfields);

%End of optimization, cancelling untouched
e_tot_opt = E_opt{1};
for i=2:length(E_opt)
    e_tot_opt = e_tot_opt + E_opt{i};
end

p_opt = abs_sq(e_tot_opt); %In the PDF, this is P_1

% -------------- FIRST FREQUENCY -----------------------
disp('---POST-OPTIMIZATION--M1-')

disp(strcat('Post-optimization-M1, HTQ= ',num2str(HTQ(p_opt,tumor_mat,healthy_tissue_mat))))
wave_opt = e_tot_opt.C.values;
ant_opt = e_tot_opt.C.keys;

for i=1:length(wave_opt)
    Amp(i) = abs(wave_opt(i));
    Pha(i) = rad2deg(phase(wave_opt(i)));
end

disp('ANTENNA SETTINGS')
disp('AMPLITUDE - PHASE - ANTENNA')

settings_1 = [Amp' Pha' ant_opt']; %For first frequency
settings_1 = sortrows(settings_1,3);
settings_1 = [];

% -------------- SECOND FREQUENCY -----------------------
disp('OPTIMIZATION - C') % cost function

disp('Figure shows C-values, not HTQ.')
[X, E_opt] = OptimizeC(e_f2,p_opt,tumor_oct); % p_opt från M1 används som vikt

e_tot_opt_c = E_opt{1};
for i=2:length(E_opt)
    e_tot_opt_c = e_tot_opt_c + E_opt{i};
end

p_opt_c = abs_sq(e_tot_opt_c); %In the PDF, this is P_2

wave_opt = e_tot_opt_c.C.values;
ant_opt = e_tot_opt_c.C.keys;

for i=1:length(wave_opt)
    Amp(i) = abs(wave_opt(i));
    Pha(i) = phase(wave_opt(i));
end

disp('ANTENNA SETTINGS')
disp('AMPLITUDE - PHASE - ANTENNA')

settings_2 = [Amp' Pha' ant_opt']; %For second frequency
settings_2 = sortrows(settings_2,3);
settings_2(:,3) = [];

disp(strcat('OPTIMIZATION - HTQ with two frequencies: ',num2str(f_1),' and ',num2str(f_2)))

% Time settings, x
f = @(x)(HTQ(x*p_opt_c+(1-x)*p_opt,tumor_mat,healthy_tissue_mat));
lb = zeros(1,1);
ub = ones(1,1);
options = optimoptions('particleswarm','SwarmSize',20,'PlotFcn',@pswplotbestf, 'MaxIterations', 50, 'MaxStallIterations', 7);
x = particleswarm(f,1,lb,ub,options);

%Combine p-matrices of both frequencies
p_opt_htq = x*p_opt_c + (1-x)*p_opt; 

disp(strcat('Post-optimization, HTQ= ',num2str(HTQ(p_opt_htq,tumor_mat,healthy_tissue_mat))))

mat_1 = p_opt.to_mat;
mat_2 = p_opt_c.to_mat;
mat_3 = p_opt_htq.to_mat;

resultpath = [rootpath filesep '..' filesep '..' filesep 'Results' filesep 'P_and_unscaled_settings'];

if ~exist(resultpath,'dir')
    disp(['Creating result folder at ' resultpath]);
    [success,message,~] = mkdir(resultpath);
    if ~success
        error(message);
    end
end

for i = 1:length(freq)          
Pname = ['P_' num2str(i) 'of' num2str(length(freq)) '_' modelType '_' num2str(freq(i)) 'MHz.mat'];
pname = ['mat_' num2str(i)];
save([resultpath filesep Pname], pname, '-v7.3');
end
freqstr = regexprep(num2str(freq),'[^\w'']','');
P12name = ['P_' modelType '_' freqstr 'MHz.mat']; % sammanslaget P för både frek1 och frek2, bara för visning
save([resultpath filesep P12name], 'mat_3', '-v7.3');
writeSettings(resultpath, [settings_1 settings_2], x, modelType, freq);

% Empty load_maestro
Yggdrasil.Utils.Efield.load_maestro('empty');

end