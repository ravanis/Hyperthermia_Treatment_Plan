function [] = EF_optimization_double(freq, nbrEfields, modelType, goal_function, particle_settings)
%[P] = EF_OPTIMIZATION()
%   Calculates an optimization of E-fields for two frequencies to maximize
%   power in tumor while minimizing hotspots. All frequency combinations
%   will be tested and PLD and settings for the combination with best HTQ
%   will be saved to results folder.
% -----INPUTS------------------------------------------------------------
% Freq:              Vector with 2 frequencies to be optimized.
% nbrEfields:        number of Efields to be optimized. If this is lower
%                    than number of antennas, antennas with low power
%                    contribution is cut off.
% modelType:         string with model name. Duke- or Child models are accepted.
% goal_function:     string with which goal function to be optimized.
%                    Options are 'M1-M1', which will optimize over M1 and
%                    show M1 in particleswarm, 'M1-HTQ' which will optimize
%                    over M1 and show HTQ in particleswarm, or 'M2' which
%                    will optimize over M2.
% particle_settings: vector with [swarmsize, max_iterations, stall_iterations]
%                    for particleswarm.
%-------------------------------------------------------------------------
tic
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
if startsWith(lower(modelType), 'duke')==1
    water_ind = 81;
    ext_air_ind = 1;
    int_air_ind = 2;
    tumor_ind = 80;
    salt_ind = 82;
elseif startsWith(lower(modelType), 'child')==1
    water_ind = 30;
    ext_air_ind = 1;
    int_air_ind = 5;
    tumor_ind = 9;
end

healthy_tissue_mat = tissue_mat~=water_ind & ...
    tissue_mat~=ext_air_ind & ...
    tissue_mat~=tumor_ind & ...
    tissue_mat~=int_air_ind & ...
    tissue_mat~=salt_ind;

tumor_oct = Yggdrasil.Octree(single(tissue_mat==tumor_ind));
healthy_tissue_oct = Yggdrasil.Octree(single(healthy_tissue_mat));
tumor_mat = tissue_mat==tumor_ind;

e_tot_f1 = e_f1{1};
for j = 2:length(e_f1)
    e_tot_f1 = e_tot_f1 + e_f1{j};
end

e_tot_f2 = e_f2{1};
for j = 2:length(e_f2)
    e_tot_f2 = e_tot_f2 + e_f2{j};
end

disp('-----PRE-OPTIMIZATION------------------------')

p_tot_f1 = abs_sq(e_tot_f1);
p_tot_f2 = abs_sq(e_tot_f2);

disp(strcat('Pre-optimization, HTQ ',num2str(f_1),'MHz= ',...
    num2str(HTQ(p_tot_f1,tumor_mat,healthy_tissue_mat))))
disp(strcat('Pre-optimization, HTQ ',num2str(f_2),'MHz= ',...
    num2str(HTQ(p_tot_f2,tumor_mat,healthy_tissue_mat))))

switch goal_function
    case 'M1-M1'
        eval_function='M1';
        disp('Preparing to optimize M1. First two figures show M1-values. Last figure shows HTQ.')
        disp(['M1 Value pre-optimization for ' num2str(f_1) 'MHz: ' num2str(M1(p_tot_f1,tumor_oct,healthy_tissue_oct))])
        disp(['M1 Value pre-optimization for ' num2str(f_2) 'MHz: ' num2str(M1(p_tot_f2,tumor_oct,healthy_tissue_oct))])
    case 'M1-HTQ'
        eval_function='HTQ';
        disp('Preparing to optimize M1. All figures shows HTQ.')
        goal_function='M1-M1';
    case 'M2'
        eval_function='M2';
        disp('Preparing to optimize M2. First two figures show M2-values. Last figure shows HTQ.')
        disp(['M2 Value pre-optimization for ' num2str(f_1) 'MHz: ' num2str(M2(p_tot_f1,tumor_oct,healthy_tissue_oct))])
        disp(['M2 Value pre-optimization for ' num2str(f_2) 'MHz: ' num2str(M2(p_tot_f2,tumor_oct,healthy_tissue_oct))])
end

% Initialize cells to check each combination
% Combinations: f1-f2,f2-f2,f2-f1,f1-f1
e_cell={e_f1,e_f2,e_f2,e_f1,e_f1};
f_cell={f_1,f_2,f_2,f_1,f_1};
e_prev=cell(1,2);

for i=1:4
    % -------------- FIRST FREQUENCY -----------------------
    disp(['-----OPTIMIZATION combo ',num2str(f_cell{i}),'MHz-', num2str(f_cell{i+1}),'MHz-------'])
    %Calculate the first fields only once per frequency
    if i<3
        e_firstIt=e_cell{i};
        
        % Optimize according to goal function.
        switch goal_function
            case 'M1-M1'
                [E_opt] = OptimizeM1(e_firstIt,tumor_oct,healthy_tissue_oct,nbrEfields,...
                    particle_settings, eval_function);
            case 'M2'
                [E_opt] = OptimizeM2(e_firstIt,tumor_oct,healthy_tissue_oct,nbrEfields,...
                    particle_settings, eval_function);
        end
        
        e_f1_opt = E_opt{1};
        for j=2:length(E_opt)
            e_f1_opt = e_f1_opt + E_opt{j};
        end
        % save eField for next iterations
        e_prev{i} = e_f1_opt; %It1: f1, It2: f2.
    elseif i==3
        % Use previously calculated fields in iteration 3 and 4
        e_f1_opt = e_prev{2}; %It3: f2, It4: f1
        disp('Using calculated field...')
    elseif i==4
        e_f1_opt = e_prev{1};
        disp('Using calculated field...')
    end
    
    p_f1_opt = abs_sq(e_f1_opt); %PLD of first frequency
    disp(['Current HTQ: ',num2str(HTQ(p_f1_opt,tumor_mat,healthy_tissue_mat))])
    
    % -------------- SECOND FREQUENCY -----------------------
    disp('OPTIMIZATION - second field')
    e_secondIt=e_cell{i+1};
    % weight next field with previos P_opt in healthy tissue
    weight_nom=Yggdrasil.Math.scalar_prod(healthy_tissue_oct,p_f1_opt);
    
    switch goal_function
        case 'M1-M1'
            [E_opt] = OptimizeM1(e_secondIt,tumor_oct,weight_nom,nbrEfields,...
                particle_settings, eval_function,healthy_tissue_oct);
        case 'M2'
            [E_opt] = OptimizeM2(e_secondIt,tumor_oct,weight_nom,nbrEfields,...
                particle_settings, eval_function,healthy_tissue_oct);
    end
    
    e_f2_opt = E_opt{1};
    for j=2:length(E_opt)
        e_f2_opt = e_f2_opt + E_opt{j};
    end
    
    p_f2_opt = abs_sq(e_f2_opt); %PLD of second frequency
    disp(['Current HTQ: ',num2str(HTQ(p_f2_opt,tumor_mat,healthy_tissue_mat))])
    disp('OPTIMIZATION - combining two frequencies')
    
    % Time settings: first freq 1-x, second freq x
    f = @(x)(HTQ(abs_sq(x*e_f2_opt+(1-x)*e_f1_opt),tumor_mat,healthy_tissue_mat));
    lb = zeros(1,1);
    ub = ones(1,1);
    % Particle settings different than the rest since this is only a
    % scalar variable x
    options = optimoptions('particleswarm','SwarmSize',5,'PlotFcn',...
        @pswplotbestf,'MaxIterations', 10, 'MaxStallIterations', 5);
    x = particleswarm(f,1,lb,ub,options);
    
    %Combine efields of both frequencies, weighted with x
    p_opt_htq = abs_sq(x*e_f2_opt+(1-x)*e_f1_opt);
    HTQ_curr=HTQ(p_opt_htq,tumor_mat,healthy_tissue_mat);
    
    disp(strcat('ITERATION DONE: Current combination HTQ= ',num2str(HTQ_curr)))
    disp(['Time share: First field: ',num2str(1-x),', second field: ',num2str(x)])
    
    %See if current iteration is better than the last: in that case, save
    %variables
    if i==1
        HTQ_best=HTQ_curr;
        bestIt=1;
        e_opt_1=e_f1_opt;
        e_opt_2=e_f2_opt;
        p_opt_1=p_f1_opt;
        p_opt_2=p_f2_opt;
        p_opt=p_opt_htq;
    elseif HTQ_curr<HTQ_best
        HTQ_best=HTQ_curr;
        bestIt=i;
        e_opt_1=e_f1_opt;
        e_opt_2=e_f2_opt;
        p_opt_1=p_f1_opt;
        p_opt_2=p_f2_opt;
        p_opt=p_opt_htq;
    end
end

disp('-----POST-OPTIMIZATION----------------------')
disp(['Best combination: ',num2str(f_cell{bestIt}),'MHz with ',num2str(f_cell{bestIt+1}),'MHz. HTQ= ',num2str(HTQ_best)])

% Calculate settings for each Efield
wave_opt = e_opt_1.C.values; %Complex amplitudes
ant_opt = e_opt_1.C.keys; %Corresponding antennas
Amp=zeros(length(wave_opt),1);
Pha=zeros(length(wave_opt),1);

for i=1:length(wave_opt)
    Amp(i) = abs(wave_opt(i));
    Pha(i) = rad2deg(phase(wave_opt(i)));
end

settings_1 = [Amp Pha ant_opt']; %For first frequency
settings_1 = sortrows(settings_1,3);
settings_1(:,3)=[];

wave_opt = e_opt_2.C.values;
ant_opt = e_opt_2.C.keys;

for i=1:length(wave_opt)
    Amp(i) = abs(wave_opt(i));
    Pha(i) = phase(wave_opt(i));
end

settings_2 = [Amp Pha ant_opt']; %For second frequency
settings_2 = sortrows(settings_2,3);
settings_2(:,3) = [];

mat_1 = p_opt_1.to_mat;
mat_2 = p_opt_2.to_mat;
mat_3 = p_opt.to_mat;

%Save P matrices
resultpath = [rootpath filesep '..' filesep '..' filesep 'Results' filesep 'P_and_unscaled_settings'];

if ~exist(resultpath,'dir')
    disp(['Creating result folder at ' resultpath]);
    [success,message,~] = mkdir(resultpath);
    if ~success
        error(message);
    end
end
freq_opt=[f_cell{bestIt} f_cell{bestIt+1}];
for i = 1:2
    Pname = ['P_' num2str(i) 'of' num2str(2) '_' modelType '_' num2str(f_cell{bestIt+i-1}) 'MHz.mat'];
    pname = ['mat_' num2str(i)];
    save([resultpath filesep Pname], pname, '-v7.3');
end
freqstr = regexprep(num2str(freq_opt),'[^\w'']','');
P12name = ['P_' modelType '_' freqstr 'MHz.mat'];
save([resultpath filesep P12name], 'mat_3', '-v7.3');

% Compute settings txt-file
writeSettings(resultpath, [settings_1 settings_2], modelType, freq_opt, [1-x x]);

% Empty load_maestro
Yggdrasil.Utils.Efield.load_maestro('empty');
toc
end