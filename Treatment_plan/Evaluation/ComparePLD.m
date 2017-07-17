% Plot and calcualte quality indicators
% Name Matlab field PLD1, CST field PLD2. 

freq=450; % Enter frequency
modelType='duke_tongue';

filename=which('CalculatePLD');
[scriptpath,~,~] = fileparts(filename);
tissuePath=[scriptpath,'\Data\df_duke_neck_cst_', num2str(freq),'MHz.txt'];
load([scriptpath, '\Data\tissue_mat_',modelType,'.mat']);

[HTQ1, ~, TC1]=getHTQ(tissue_Matrix, PLD1, modelType);
[HTQ2, ~, TC2]=getHTQ(tissue_Matrix, PLD2, modelType);
data = prctile(PLD1(:),linspace(1,100));

% Display quality indicators
disp(['MATLAB ', num2str(freq), 'MHz']);
disp(strcat('Mean: ',num2str(mean(PLD1(:)))));
disp(strcat('Standard Deviation: ',num2str(std(PLD1(:)))));
disp(strcat('Maximum value: ',num2str(max(PLD1(:)))));
disp(strcat('99 percentile: ',num2str(data(99))));
disp(strcat('100 percentile: ',num2str(data(100))));
disp(['HTQ value: ', num2str(HTQ1)]);
disp('------------------------------');

data = prctile(PLD2(:),linspace(1,100));

disp(['CST ', num2str(freq), 'MHz']);
disp(strcat('Mean: ',num2str(mean(PLD2(:)))));
disp(strcat('Standard Deviation: ',num2str(std(PLD2(:)))));
disp(strcat('Maximum value: ',num2str(max(PLD2(:)))));
disp(strcat('99 percentile: ',num2str(data(99))));
disp(strcat('100 percentile: ',num2str(data(100))));
disp(['HTQ value: ', num2str(HTQ2)]);

% Plot in myslicer
set(figure(1),'name',['Matlab', num2str(freq),'MHz'],'numbertitle','off');
title(['PLD Matlab ',num2str(freq),'Mhz'])
myslicer(PLD1);

set(figure(2),'name',['CST', num2str(freq),'MHz'],'numbertitle','off');
title(['PLD CST ',num2str(freq),'Mhz'])
myslicer(PLD2);
