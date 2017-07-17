% Compares tissue_files from CST Duke with database values from dataBaseOrdered.txt 
% Set path for material folder, CST tissue file name and percentage limit
% of difference. Script returns names and values of tissues which differs
% more than limit.

materialPath='C:\Users\Julia\Desktop\Kandidat\tissue_files\'; 
tissueName='df_duke_neck_cst_425MHz_test.txt';
limitFault=0.02; % Limit of percentage difference

materialFile=[materialPath, 'dataBaseOrdered.txt'];
paramMat=caseread(materialFile);
[nameRef, ~, epsRef, sigmaRef] = strread(paramMat', ' %s %s %f %f', 'whitespace', '\t');

materialFile1=[materialPath, tissueName];
paramMat1=caseread(materialFile1);
paramMat1(end-11:end,:)= [];   % last materials (air, water, tumor etc) not in dataBase

[nameCol, ~, epsCol, ~, sigmaCol, ~] = strread(paramMat1', ' %s %d %f %d %f %f', 'whitespace', '\t');
sigmaCol(13:14)=[]; % materials on index 13 and 14 not on dataBase (ear_skin and ear_cartilage)
nameCol(13:14)=[];
epsCol(13:14)=[];

% Calculate Percentage difference
sigmaDiff=(sigmaRef - sigmaCol)./sigmaCol;
epsDiff=(epsRef-epsCol)./epsCol;
indexFault=find(abs(epsDiff)>limitFault);

nameCol(indexFault)
sFault=sigmaDiff(indexFault)*100
eFault=epsDiff(indexFault)*100

clear paramMat* material* tissueName



