% Compares settings derived from optimization to those from time reversal

%------- INPUT PARAM -------

modelType='cylinder';

freq=450; % Frequency in MHz

isSingle=1; % Boolean that states if there is only one frequency

% Path to result location, not ending with \
resultpath = 'D:\kandFFT\Results\Cylinder\450MHz';

numAnts=10; % Number of antennas

% Absolute path to optimization settings ends with .txt
settingPath1='settings_cylinder_450MHz_none.txt';

% Absolute path to time reversal settings ends with .txt
%settingPath2='D:\MATLAB\Focus ability of antenna placement\output_files\settings_cylinder_450MHz.txt';
settingPath2='D:\MATLAB\Phase and Amplitude\output_files\settings_cylinder_450MHz.txt';
%---------------------------

% generates data path
filename = which('create_sigma_mat');
[scriptpath,~,~] = fileparts(filename);
datapath = [scriptpath filesep '..' filesep 'Data'];

disp('loads initial data ...')
% reads settings

[settings1, timeShare1, ~] = readSettings( settingPath1, isSingle );

[settings2, timeShare2, ~] = readSettings( settingPath2, isSingle );

% loads tissue matrix

tissue_mat = Yggdrasil.Utils.load([datapath filesep 'tissue_mat_' modelType '.mat']);

% loads sigma matrix

SigmaMat=cell(length(freq),1);

for i=1:length(freq)
    
    SigmaMat{i}=Yggdrasil.Utils.load([datapath filesep 'sigma_' modelType '_' num2str(freq(i)) 'MHz.mat']);
    
end


disp('loads Efields ...')
% loads Efields

Efields=cell(numAnts,length(freq));

for i=1:length(freq)
    
    for j=1:numAnts
            Efields{j,i}=Yggdrasil.Utils.load([resultpath filesep 'Efield_' num2str(freq(i)) 'MHz_A' num2str(j) '_' modelType '.mat']);
    end
    
end


disp('applies settings to Efields ...')
% allplies settings to Efields

E1=cell(length(freq),1);
E2=cell(length(freq),1);

for i=1:length(freq)    
    
    E=Efields{1,i};
    
    E1{i}=E*settings1(1,1)*exp(-1i*settings1(1,2));
    
    E2{i}=E*settings2(1,1)*exp(1i*settings2(1,2));
    
    
    for j=2:numAnts
        
        E=Efields{j,i};
        
        E1{i}=E1{i}+E*settings1(j,2*i-1)*exp(-1i*settings1(j,2*i));
        
        E2{i}=E2{i}+E*settings2(j,2*i-1)*exp(1i*settings2(j,2*i));
        
    end
    
end


disp('calculates PLD ...')
% calculates PLD

if isSingle
    
    E1=E1{1};E2=E2{1};
    PLD1=sum(abs(E1).^2,4).*SigmaMat{1};
    PLD2=sum(abs(E2).^2,4).*SigmaMat{1};
    
else
    
    SigmaMat1=cat(4,SigmaMat{1},SigmaMat{1},SigmaMat{1});
    SigmaMat2=cat(4,SigmaMat{2},SigmaMat{2},SigmaMat{2});
    PLD1=sum(abs(E1{1}*timeShare1(1).*sqrt(SigmaMat1)+E1{2}*timeShare1(2).*sqrt(SigmaMat2)).^2,4);
    PLD2=sum(abs(E2{1}*timeShare2(1).*sqrt(SigmaMat1)+E2{2}*timeShare2(2).*sqrt(SigmaMat2)).^2,4);
    
end


disp('calculates QI ...')

% calculates quality indicators

[HTQ1, PLDmaxTum1, TC1]=getHTQ(tissue_mat, PLD1, modelType);

[HTQ2, PLDmaxTum2, TC2]=getHTQ(tissue_mat, PLD2, modelType);

disp(['HTQ for setting 1 is ' num2str(HTQ1)])
disp(['TC25 for setting 1 is ' num2str(TC1(1))])
disp(['Maximum PLD in tumor for setting 1 is ' num2str(PLDmaxTum1) ' W'])

disp(['HTQ for setting 2 is ' num2str(HTQ2)])
disp(['TC25 for setting 2 is ' num2str(TC2(1))])
disp(['Maximum PLD in tumor for setting 2 is ' num2str(PLDmaxTum2) ' W'])

disp(['HTQ difference is ' num2str(abs(HTQ1-HTQ2))])
disp(['TC25 difference is ' num2str(abs(TC1(1)-TC2(1)))])
disp(['Difference in Maximum PLD in tumor is ' num2str(abs(PLDmaxTum1-PLDmaxTum2)) ' W'])

figure(1)
myslicer(100*PLD1/(max(PLD1(:))));
title('PLD distribution for settings 1')
figure(2)
myslicer(100*PLD2/(max(PLD2(:))));
title('PLD distribution for settings 2')

disp('done!')

