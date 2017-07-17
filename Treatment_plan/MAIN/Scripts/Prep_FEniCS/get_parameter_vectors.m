function [thermal_conductivity, perf_cap, modified_perf_cap, heat_trans, temp_out] =...
          get_parameter_vectors(keyword, modelType)
% [thermal_conductivity, perf_cap, modified_perf_cap, heat_trans, temp_out] = GET_PARAMETER_VECTORS(path_name)
% Loads the data from a file specific type of file created by
% reload_parameters.m and outputs the four collums as arrays.

%% Load data from .m files

% Gets the boundrary conditions
heat_trans = boundary_condition();

% Sets the values for the temperatures in the same order as heat_trans
temp_out = temperature();

%% Load data from .txt file
% Reads the file with material properties
% In the read data the values for the tumor is incorrect
path = get_path(keyword, modelType);
paramMat = caseread(path);
paramMat(end,:)= []; % Removes the last two rows
[name, ~, heat_cap, thermal_conductivity, perf, modified_perf, dens] =...
strread(paramMat', '%s %d %f %f %f %f %f', 'whitespace', '\t');

% Finds the index of blood
if startsWith(modelType, 'duke')
index_blood = strfind(name, 'BloodA');
index_blood = find(not(cellfun('isempty', index_blood)));
end

% Multiplies the heat capacity and density of blood with the perfusion and
% density of other materials
if startsWith(modelType, 'duke')
perf_cap = heat_cap(index_blood) .* perf .* dens .* dens(index_blood);
modified_perf_cap = heat_cap(index_blood) .* modified_perf .* dens .* dens(index_blood);
elseif modelType == 'child'
    heat_cap = 3617; %Use duke values to model blood perfusion since child does not have blood in model
    dens = 1040; % Use duke values... 
    perf_cap = heat_cap .* perf .* dens .* dens;
    modified_perf_cap = heat_cap .* modified_perf .* dens .* dens;
end
end