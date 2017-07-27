function generate_fenics_parameters(modelType, freq, overwriteOutput, overwriteModel)
%GENERATE_FENICS_PARAMETERS(overwriteOutput, overwriteModel)
%   Generates the mesh and matrices with parameters used by pennes.py.
%   This function are done in five steps:
%   1. Set-up, initalize parameters and load necessary data from model
%   2. Generate meshes
%   3. (Optional) Stage 1, gather and collect data from databases
%   4. Stage 2, create parameter matrices based on indexed model
%   5. Final stage, extrapolate the .mat files using nearest neighbor
%
%Input:
% overwriteOutput: Option to regenerate matrices, default is false
% overwriteModel: Option to recreate the model, default is false
if nargin < 3
    overwriteOutput = false;
end
if nargin < 4
    overwriteModel = false;
end
if startsWith(modelType,'duke') == 0 % Needs to be redone once for a new model, not only not-duke
    disp(['Model needs to be recreated. Set overwriteOutput ' ...
        'overwriteModel to true in Main: Generate FEniCS parameters.'])
end

% Get root path
filename = which('generate_fenics_parameters');
[preppath,~,~] = fileparts(filename);
scriptpath = [preppath filesep '..'];
resultpath = [preppath filesep '..' filesep '..' filesep 'Results' filesep ...
    'Input_to_FEniCS' filesep modelType];
if ~exist(resultpath,'dir')
    disp(['Creating result folder at ' resultpath]);
    [success,message,~] = mkdir(resultpath);
    if ~success
        error(message);
    end
end

%% 1. Initilize and load model
disp('1. Initilize and load model')
% Import packages and addpaths
import Extrapolation.*
if strcmp(which('Extrapolation.load'), '')
    error('Need addpath to the self-developed package ''Extrapolation''.')
end

addpath(preppath, scriptpath)
addpath(get_path('tissue_data'))

tissue_mat = Extrapolation.load(get_path('mat_index', modelType));

if startsWith(modelType, 'duke') == 1
    tumor_ind = 80;
    muscle_ind = 48;
    cerebellum_ind = 12;
    water_ind = 81;
    ext_air_ind = 1;
    int_air_ind = 2;
elseif startsWith(modelType,'child') == 1
    tumor_ind = 9;
    muscle_ind = 3;
    cerebellum_ind = 8;
    water_ind = 30;
    ext_air_ind = 1;
    int_air_ind = 5;
else
    error('Model type not available. Enter your model indices in generate_fenics_parameters.')
end
disp('initialization done')

%% 2. Generate mesh
disp('2. Generating meshes')
% Options for the mesh generation
rad_bound = 7;
dist_bound = 1;
tet_vol = 15;
% Ignore water and exterior air and interior air
bin_mat = tissue_mat ~= water_ind...
    & tissue_mat ~= ext_air_ind;

if ~exist(get_path('mesh', modelType), 'file') || overwriteModel
    disp('Generating mesh from indexed model.')
    % Create the mesh
    bin_to_mesh(get_path('mesh', modelType), bin_mat, rad_bound, dist_bound, tet_vol);
else
    disp('Model mesh already exists, using exsisting one. Delete to generate new mesh.')
end
if ~exist(get_path('tumor_mesh', modelType), 'file') || overwriteModel
    disp('Generating tumor mesh.')
    % Create a tumor mesh
    bin_to_mesh(get_path('tumor_mesh', modelType), tissue_mat == tumor_ind, rad_bound, dist_bound, tet_vol);
else
    disp('Tumor mesh already exists, using existing one. Delete to generate new mesh.')
end
disp('Meshing done')
%% 3. Stage 1 (Optional)
% Turns on/off Stage 1, which will gather all data from databases
do_stage_1 = false;

if do_stage_1
    disp('3. Stage 1: Compiling database data')
    % Collect parameter data from databases and save as a textfile
    combine_raw(modelType);
    disp('Compilation done')
else
    disp('(Skipping) 3. Stage 1: Compiling database data')
    disp('Will use precompiled data.')
end

%% 4. Stage 2
disp('4. Stage 2: Creating parameter matrices based on indexed model')
% Read the textfile created in Stage 1 and save the data as .mat files

if do_stage_1 % The file to load depends if stage_1 is turned on
    thermal_comp_keyword = 'stage1_thermal_compilation';
else % If stage 1 is turned off then use premade compilation
    thermal_comp_keyword = 'premade_thermal_compilation';
end
[thermal_conductivity, rest_perf_cap, modified_perf_cap, bnd_heat_trans, bnd_temp] =...
    get_parameter_vectors(thermal_comp_keyword, modelType);
if endsWith(modelType, 'salt')
    thermal_conductivity(82) = 0.596; % Salt water conductivity OBS fel salthalt
end

% Finalize boundary condition
create_bnd_matrices(overwriteOutput, tissue_mat, water_ind, bnd_heat_trans, bnd_temp, modelType);

create_vol_matrices(overwriteOutput, tissue_mat, thermal_conductivity, modified_perf_cap, modelType);
disp('Matrices done.')
%% 5. Final
disp('5. Final stage: Extrapolating data.')

% See help finalize for explanation
exist_thermal   = exist(get_path('xtrpol_thermal_cond_mat', modelType), 'file');
exist_perfusion = exist(get_path('xtrpol_perfusion_heatcapacity_mat', modelType), 'file');
if length(freq)>1
    path = get_path('xtrpol_PLD_multiple', modelType, freq);
    exist_PLD       = exist(path{1}, 'file');
elseif length(freq)==1
    exist_PLD       = exist(get_path('xtrpol_PLD_single', modelType, freq), 'file');
end
if ~all([exist_thermal, exist_perfusion, exist_PLD]) || overwriteOutput
    % Get the nearest element inside the body and distances to the element for
    % all elements
    interior_mat = tissue_mat ~= water_ind & tissue_mat ~= ext_air_ind;
    [~,nearest_points] = Extrapolation.meijster(interior_mat);
    
    if ~exist_thermal
        finalize('thermal_cond_mat', nearest_points, modelType);
    end
    if ~exist_perfusion
        finalize('perfusion_heatcapacity_mat', nearest_points, modelType);
    end
    if ~exist_PLD
        if length(freq)==1
            if ~exist(get_path('PLD_single', modelType, freq), 'file')
                error(['Missing PLD (Power loss density) at ''' get_path('PLD', modelType, freq) '''.'])
            end
        elseif length(freq)>1
            pldmultipath = get_path('PLD_multiple', modelType, freq);
            if ~exist(pldmultipath{1}, 'file')
                error(['Missing PLD (Power loss density) at ''' pldmultipath '''.'])
            end
        end
        if length(freq)==1
            finalize('PLD_single', nearest_points, modelType, freq);
        elseif length(freq)>1
            finalize('PLD_multiple', nearest_points, modelType, freq);
        end
    end
end

disp('Extrapolation done')
disp('---------------------------')
disp('FEniCS parameters generated')
disp('---------------------------')
end