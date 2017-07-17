% Addpaths
% addpath ..
% addpath Libs/iso2mesh
% addpath Libs/myslicer
% addpath MAIN
% addpath Evaluation
% addpath Evaluation/quality_indicators

filename = which('hyp_init');
[rootpath,~,~] = fileparts(filename);
evalpath = [rootpath filesep 'Evaluation'];
qualpath = [evalpath filesep 'quality_indicators'];
libpath = [rootpath filesep 'Libs'];
isopath = [libpath filesep 'iso2mesh'];
mypath = [libpath filesep 'myslicer'];