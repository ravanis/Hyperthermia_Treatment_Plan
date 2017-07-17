function [] = EF_optimization_multiple(freq, nbrEfields, modelType)
%[P] = EF_OPTIMIZATION()
%   Calculates a optimization of E-fields to maximize power in tumor while
%   minimizing hotspots. The resulting power loss densities and antenna settings  will then be
%   saved to the results folder under P_and_unscaled_settings.

% Ensure Yggdrasil is available
if strcmp(which('Yggdrasil.Octree'), '')
    error('Need addpath to the self-developed package ''Yggdrasil''.')
end

% Get root path
filename = which('EF_optimization_multiple');
[optpath,~,~] = fileparts(filename);
datapath = [optpath filesep '..' filesep '..' filesep 'Data'];
scriptpath = [optpath filesep '..' filesep '..' filesep 'Scripts'];
addpath(scriptpath)

% Initialize load_maestro to be able to load E_fields
Efilename = @(f,a)[datapath filesep 'Efield_' num2str(f) 'MHz_A' num2str(a) '_' modelType];
sigma     = @(f)[datapath filesep 'sigma_' modelType '_' num2str(f) 'MHz'];
rel_eps = 0.1;
Yggdrasil.Utils.Efield.load_maestro('init', Efilename, sigma, rel_eps);
n = nbrEfields; %Nmbr of Antennas

% Convert sigma from .txt to a volumetric matrix
for f = freq
    create_sigma_mat(f, modelType);
end

% Create Efield objects for several frequencies
% Think in terms of frequency first, then antenna.

e_f = cell(1,length(freq),n);
for i = 1:n
    for j=1:length(freq)
        e_f{1,j,i} = Yggdrasil.SF_Efield(freq(j),i);
    end
end

%Creating settings for all antennas, for all frequencies
settings = zeros(n,2,length(freq));

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

%This is the matrix that stores every optimized PLD
dim = size(tissue_mat);
P_opt_f = zeros(dim(1),dim(2),dim(3),length(freq));

%This for-loop below evaluates HTQ for every frequency prior to
%optimization. A continuation here would be an ordering of E-fields and
%then optimize according to some ordering by HTQ.
disp('---PRE-OPTIMIZATION---')
for f=1:length(freq)
    e_tot = e_f{1,f,1};
    for i = 2:n
        e_tot = e_tot + e_f{1,f,i};
    end
    p_tot = abs_sq(e_tot);
    disp(['For frequency : ' num2str(freq(f)) ' HTQ is ' num2str(HTQ(p_tot,tumor_mat,healthy_tissue_mat))])
end

%Optimization step 1: optimization of M1 at the first frequency
%Some quick fix needs to be added, since cell vectors are really
%odd.
[X, E_opt] = OptimizeM1({e_f{1,1,:}},tumor_oct,healthy_tissue_oct, nbrEfields);

%End of optimization, cancelling untouched e-fields
e_tot_opt = E_opt{1};
for i=2:length(E_opt)
    e_tot_opt = e_tot_opt + E_opt{i};
end

p_opt = abs_sq(e_tot_opt); %In the PDF, this is P_1

disp('---POST-OPTIMIZATION---')
disp('OPTIMIZATION - M1 (first frequency)')
disp(['For frequency ' num2str(freq(1)) ' MHz'])
%disp(strcat('Post-optimization, M1= ',num2str(M1(p_opt,tumor_oct,healthy_tissue_oct))))
wave_opt = e_tot_opt.C.values;
ant_opt = e_tot_opt.C.keys;

for i=1:length(wave_opt)
    Amp(i) = abs(wave_opt(i));
    Pha(i) = rad2deg(phase(wave_opt(i)));
end

disp('ANTENNA SETTINGS')
disp('AMPLITUDE - PHASE - ANTENNA')

AntennaSettings = [Amp' Pha' ant_opt'] %For first frequency
AntennaSettings = sortrows(AntennaSettings,3);
AntennaSettings(:,3) = [];
settings(:,:,1) = AntennaSettings;

P_opt_f(:,:,:,1) = p_opt.to_mat;

%This is the main part of the optimization
 disp('OPTIMIZATION - C (remaining frequencies)')
for f=2:length(freq)
    disp(['For frequency ' num2str(freq(f)) ' MHz'])
 
    %NOTE: The first argument has to have {}, or else the data is
    %considered to be elements of a cell vectors, and not a cell vector.
    %OptimizeC requires a cell vectors of E-fields, not seperate E-fields.
    [X, E_opt] = OptimizeC({e_f{1,f,:}},tumor_oct,CompositePLD(P_opt_f,f-1));
    
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
    
    AntennaSettings  = [Amp' Pha' ant_opt']
    AntennaSettings  = sortrows(AntennaSettings ,3);
    AntennaSettings(:,3) = [];
    settings(:,:,f) = AntennaSettings;
    P_opt_f(:,:,:,f) = p_opt_c.to_mat;
    
end

disp(strcat('OPTIMIZATION - HTQ (calculating optimal time settings)'))

f = @(x)(HTQ(HTQ_multiple(x,P_opt_f),tumor_mat,healthy_tissue_mat));

%Combine them
x0 = ones(1,length(freq))*(length(freq))^-1;
A=[];
b=[];
lb = zeros(1,length(freq));
ub = ones(1,length(freq));
Aeq = ones(1,length(freq));
beq = [1];

%WE NEED WORKING BOUNDS HERE. Every element in the vector x should be more
%than 0 and the sum of all the elements should be 1.
x = patternsearch(f,x0,A,b,Aeq,beq,lb,ub);
p_opt_htq = CreateOptimalPLD(x,P_opt_f);

disp(strcat('Post-optimization, HTQ= ',num2str(HTQ(p_opt_htq,tumor_mat,healthy_tissue_mat))))

mat_1 = P_opt_f; %This is the mat.file containing every PLD-matrix
mat_2 = p_opt_htq; %This is the mat-file with the optimal time distribution

resultpath = [datapath filesep '..' filesep 'Results' filesep 'P_and_unscaled_settings'];

if ~exist(resultpath,'dir')
    disp(['Creating result folder at ' resultpath]);
    [success,message,~] = mkdir(resultpath);
    if ~success
        error(message);
    end
end

%Ordering the settings in the correct way so that WriteSettings accepts
%them (settings = [amp1 fas1 amp2 fas2 amp3 fas3])
settings_tot = zeros(n,length(freq)*2);

i=1:2:2*length(freq);
for j = 1:length(freq)
    k = i(j);
    set = settings(:,:,j)
    settings_tot(:,k) = set(:,1);
    settings_tot(:,k+1) = set(:,2);
end

writeSettings(resultpath,settings_tot,modelType,freq,x);
freqstr = regexprep(num2str(freq),'[^\w'']',''); %removes spaces
save([resultpath filesep 'P_' modelType '_' freqstr 'MHz_multiple.mat'], 'mat_1', '-v7.3');
save([resultpath filesep 'P_' modelType '_' freqstr 'MHz.mat'], 'mat_2', '-v7.3');

% Empty load_maestro
Yggdrasil.Utils.Efield.load_maestro('empty');
end