function [path] = get_path(str, modelType, freq)
%function [path] = get_path(str)
%   Returns the absolute path of a file given by a keyword. This is used to
%   simplify file loading/saving.

% Relative filepaths
% input for databases and PLD
filename = which('get_path');
[scriptpath,~,~] = fileparts(filename);
tissuepath = [scriptpath filesep '..' filesep 'Data' filesep];
sourcepath = [scriptpath filesep '..' filesep 'Results' filesep 'P_and_unscaled_settings' filesep];
% temporary files
stage1path = [scriptpath filesep 'Prep_FEniCS' filesep 'tmp' filesep 'Stage1' filesep];
stage2path = [scriptpath filesep 'Prep_FEniCS' filesep 'tmp' filesep 'Stage2' filesep];

if nargin < 2
    switch(lower(str))
        case 'tissue_data'
            path = tissuepath;
        case 'scripts'
            path = 'Scripts';
        case 'mesh_scripts'
            path = ['Scripts' filesep 'Mesh_generation'];
        case 'boundary_condition'
            path = [tissuepath 'boundrary_condition.m'];
        case 'temperature'
            path = [tissuepath 'temperature.m'];
        case 'map_index'
            path = [tissuepath 'thermal_db_index_to_mat_index.m'];
        case 'thermal_db'
            path = [tissuepath 'Thermal_dielectric_acoustic_MR_'...
                'properties_database_V3.0.xlsx'];
        case 'stage1'
            path = [stage1path(1:end-1)];
        case 'stage2'
            path = [stage2path(1:end-1)];
        case 'thermal_cond_mat'
            path = [stage2path 'thermal_cond.mat'];
        case 'perfusion_heatcapacity_mat'
            path = [stage2path 'perfusion_heatcapacity.mat'];
    end
elseif nargin==2
    % output
    resultpath = [scriptpath filesep '..' filesep 'Results' filesep 'Input_to_FEniCS' filesep modelType filesep];
    switch(lower(str))
        case 'mat_index'
            path = [tissuepath 'tissue_mat_' modelType '.mat'];
        case 'rho'
            path = [tissuepath 'rho_' modelType '.mat'];
        case 'stage1_thermal_compilation'
            if startsWith(modelType,'duke')
                path = [stage1path 'thermal_compilation_duke.txt'];
            elseif startsWith(modelType,'child')
                path = [stage1path 'thermal_compilation_child.txt'];
            end
        case 'premade_thermal_compilation'
            if startsWith(modelType,'duke')
                path = [tissuepath 'thermal_compilation_duke.txt'];
            elseif startsWith(modelType,'child')
                path = [tissuepath 'thermal_compilation_child.txt'];
            end
            % Final data, ready to be used by FEniCS
        case 'bnd_heat_transfer_mat'
            path = [resultpath 'bnd_heat_transfer.mat'];
        case 'bnd_temp_mat'
            path = [resultpath 'bnd_temp.mat'];
        case 'bnd_temp_times_ht_mat'
            path = [resultpath 'bnd_temp_times_ht.mat'];
        case 'xtrpol_thermal_cond_mat'
            path = [resultpath 'thermal_cond.mat'];
        case 'xtrpol_perfusion_heatcapacity_mat'
            path = [resultpath 'perfusion_heatcapacity.mat'];
        case 'mesh'
            path = [resultpath 'mesh.xml'];
        case 'tumor_mesh'
            path = [resultpath 'tumor_mesh.obj'];
        otherwise
            error(['Unknown path to file: ''' str '''.'])
    end
else
    % output
    resultpath = [scriptpath filesep '..' filesep 'Results' filesep 'Input_to_FEniCS' filesep modelType filesep];
    switch(lower(str))
        case 'pld_single'
            path = [sourcepath 'P_' modelType '_' num2str(freq) 'MHz.mat'];
        case 'pld_multiple'
            %             [freq_comb_filename1] = find_freq_comb(modelType, freq, 'P');
            %             path = [sourcepath freq_comb_filename1];
            path = cell(length(freq),1);
            for i = 1:length(freq)
                path{i} = [sourcepath 'P_' num2str(i) 'of' num2str(length(freq)) ...
                    '_' modelType '_' num2str(freq(i)) 'MHz.mat'];
            end
        case 'xtrpol_pld_single'
            path = [resultpath 'P_' modelType '_' num2str(freq) 'MHz.mat'];
        case 'xtrpol_pld_multiple'
            %             [freq_comb_filename2] = find_freq_comb(modelType, freq, 'P');
            %             path = [resultpath freq_comb_filename2];
            path = cell(length(freq),1);
            for i = 1:length(freq)
                path{i} = [resultpath 'P_' num2str(i) 'of' num2str(length(freq)) ...
                    '_' modelType '_' num2str(freq(i)) 'MHz.mat'];
            end
        case 'sigma'
            if length(freq)==1
                path = [tissuepath 'sigma_' modelType '_' num2str(freq) 'MHz.mat'];
            elseif length(freq) >1 % bör ändras
                path = [tissuepath 'sigma_' modelType '_' num2str(freq(1)) 'MHz.mat'];
            end
        case 'cst_data'
            if startsWith(modelType, 'duke')==1
                path = [tissuepath 'df_duke_neck_cst_' num2str(freq) 'MHz.txt'];
            elseif modelType == 'child'
                path = [tissuepath 'df_chHead_cst_' num2str(freq) 'MHz.txt'];
            else
                error('Model type not available. Enter the full name of your model tissue_file in create_sigma_mat.')
            end
    end
end

end