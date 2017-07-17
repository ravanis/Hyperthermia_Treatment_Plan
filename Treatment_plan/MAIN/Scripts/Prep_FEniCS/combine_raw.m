function  combine_raw(modelType)
%COMBINE_RAW()
%   Gathers all data needed from different sources and stores them in one
%   tab separated textfile called thermal_compilation.

index_map = thermal_db_index_to_mat_index();

% Values for tumor which didn't exist in the database the rest of the data
% was gathered from
% Source http://cancerres.aacrjournals.org/content/canres/49/23/6449.full.pdf (2016-07-07)
% Mean value for Grade 3-4
perf_tumor = 0.795; % ml/(g min)
perf_tumor = perf_tumor /(1000*60); % m^3 / (kg s)

% Source http://scitation.aip.org/docserver/fulltext/aapm/journal/medphys/5/5/1.59
% 4434.pdf?expires=1467878966&id=id&accname=2113636&checksum
% =4E9941E3408E9FA5961C68CF7DAD3396 (2016-07-07)
thermal_cond_tumor = 0.89 * 1.48 * 10^(-3); % cal / (s cm degree C)
thermal_cond_tumor = thermal_cond_tumor * 4.184 * 100; % W / (m degree C)

% Read the first file and save the wanted collums
paramMat = caseread(get_path('cst_data', modelType, 400));
paramMat(end-1:end,:)= []; % Removes the last two rows

% Creates three columns containing name, index and density values
[name, index, ~, ~, ~, dens] = strread(paramMat', '%s %d %f %d %f %f',...
    'whitespace', '\t');

% Read from the database
val = xlsread(get_path('thermal_db'), 'Thermal_dielectric_acoustic_MR', '', 'basic');
heat_cap = val(index_map, 6);
thermal_conductivity = val(index_map, 11);

% Convert to SI-units
perf = val(index_map, 16)/(6e7);

% Initialize the output variabels
name_out = cell(max(index),1);
heat_cap_out = zeros(max(index));
thermal_conductivity_out = heat_cap_out;
perf_out = heat_cap_out;
dens_out = heat_cap_out;

% Transfer values corresponding to non-empty indices
heat_cap_out(index) = heat_cap;
thermal_conductivity_out(index) = thermal_conductivity;
perf_out(index) = perf;
dens_out(index) = dens;

% Some indices does not have a corresponding material initalize these...
% with the string 'Empty'
name_out(:) = {'Empty'};
name_out(index) = name;

% Indexes needed for modifying the rest perfusion
if startsWith(modelType, 'duke') == 1
    tumor_ind = 80;
    muscle_ind = 48;
    cerebellum_ind = 12;
elseif modelType == 'child'
    tumor_ind = 9;
    muscle_ind = 3;
    cerebellum_ind = 8;
else
    error('Model type not available. Enter your model indices in combine_raw.')
end

% Replace the placeholder values for the tumor
thermal_conductivity_out(tumor_ind) = thermal_cond_tumor;
perf_out(tumor_ind) = perf_tumor;

% Modify the values of blood perfusion
% Only some tissues are modeled to be heat dependent, e.g. muscle.
% But tissues such as cartilage and teeth are ignored.
ignore = [1 2 3 6 11 13 16 17 19 23 24 26 27 34 39 42 53 57 59 66 67 71 73 74 77 81];
modified_perf = modify_perf(perf_out, ignore, muscle_ind, cerebellum_ind, tumor_ind);


if ~exist(get_path('stage1'), 'dir')
    disp('Creating new directory Stage1 for storage of the combinded databases.');
    mkdir(get_path('stage1'));
end

% Save as a tab separated textfile
f = fopen(get_path('stage1_thermal_compilation'), 'w');
index_out = 1:max(index);
for i = index_out
    fprintf(f, '%s\t%d\t%g\t%g\t%g\t%g\t%g\n', name_out{i}, index_out(i),...
        heat_cap_out(i), thermal_conductivity_out(i), perf_out(i), modified_perf(i), dens_out(i));
end
fprintf(f, '%s\t%s\t%s\t%s\t%s\t%s\t%s\n', 'Material', 'Index',...
    'Heat capacity[J/kg/°C]', 'Thermal conductivity[W/m/°C]', 'Rest perfusion[m^3/s/kg]', ...
    'Modified rest perfusion[m^3/s/kg]','Density[kg/m^3]');
fclose(f);
end