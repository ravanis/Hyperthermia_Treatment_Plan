function [modelType,nbrEfields,PwrLimit,freq,particle_settings] = InputData()
% Opens window to enter input data

prompt = {'Model type:','Number of E-fields:','Antenna power limit (% of 150 W):',...
    'Particle swarm size', 'Max iterations', 'Max stall iterations',...
    'Frequency(ies), MHz, one per row:'};
title = 'Inputs';
num_lines = [1,1,1,1,1,1,5];
defaultans = {'duke_nasal','16','100','20','10','5',['400';'600']};
options.Resize = 'on';
[input] = inputdlg(prompt,title,num_lines,defaultans,options);

modelType = input{1};
nbrEfields = str2num(input{2});
PwrLimit = str2num(input{3})/100;
particle_settings = [str2num(input{4}),str2num(input{5}),str2num(input{6})];
frequencies = input{7};
f = size(frequencies);
for j = 1:f(1)
    freq(j) = str2num(frequencies(j,:));
end
end
