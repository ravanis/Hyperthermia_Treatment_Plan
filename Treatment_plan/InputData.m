function [modelType,nbrEfields,PwrLimit,goal_function,particle_settings,freq] = InputData()
% Opens window to enter input data

prompt = {'Model type:',...
    'Number of E-fields:',...
    'Antenna power limit (% of 150 W):',...
    'Goal function (M1-M1, M1-HTQ, M2):',...
    'Particle swarm size:', ...
    'Max iterations:', ...
    'Max stall iterations:',...
    'Frequency(ies), MHz, one per row:'};
title = 'Inputs';
num_lines = [1,1,1,1,1,1,1,5];
defaultans = {'duke_tongue_salt','16','100','M1-HTQ','20','20','10',['450']};
options.Resize = 'on';
[input] = inputdlg(prompt,title,num_lines,defaultans,options);

modelType = input{1};
nbrEfields = str2num(input{2});
PwrLimit = str2num(input{3})/100;
goal_function = input{4};
particle_settings = [str2num(input{5}),str2num(input{6}),str2num(input{7})];
frequencies = input{8};
f = size(frequencies);
for j = 1:f(1)
    freq(j) = str2num(frequencies(j,:));
end
end
