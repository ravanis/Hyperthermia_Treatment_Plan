% Returns the HTQ (hot spot PLD to tumor PLD quotient) and maximum PLD in
% tumor, and TC. 
% HTQ is defined as the mean in the top 1 percentile of healthy tissue
% divided by the mean in the tumor.
% TC is the tumor volume cover percentage of 25,50 and 75% of the maximum
% PLD value in healthy tissue.
% To find PLDmaxTum from PLDmaxTum, divide with rho

% Created by JW 01-14

 function [HTQ, PLDmaxTum, meanPLDnorm, TC]=getHTQ(TissueMatrix, PLD, modelType)
 
%----INPUT PARAMETERS----
% TissueMatrix - voxel data tissue matrix
% PLD - Power Loss Density matrix, it is also possible to use a PLD matrix
% NOTE: The PLD and TissueMatrix need to have the same size and
% resolution

filename = which('getHTQ');
[scriptpath,~,~] = fileparts(filename);
datapath = [scriptpath filesep '..' filesep '..' filesep 'MAIN' filesep 'Data' filesep];

if startsWith(lower(modelType), 'duke') == 1
    tissue_filepath = ([datapath 'df_duke_neck_cst_450MHz.txt']);
elseif startsWith(lower(modelType),'child')==1
    tissue_filepath = ([datapath 'df_chHead_cst_450MHz.txt']);
elseif startsWith(lower(modelType),'cylinder')==1
    tissue_filepath = ([datapath 'df_cylinder_cst_450MHz.txt']);    
else
    error('Assumed to retrieve indices for frequency 450 MHz (no matter which frequency you use), the tissuefile for this frequency is missing.')
end

[tissueData, tissue_names]=importTissueFile(tissue_filepath);

nonTissueValues=[];
tumorValue=[];
cystTumorValue=[];

for i=1:length(tissue_names)
    
    tissue_name=tissue_names{i};
    tissue_name=tissue_name(~isspace(tissue_name));
    
    if strcmpi('Tumor',tissue_name)
        tumorValue=tissueData(i,1);
    elseif strcmpi('Cyst-Tumor',tissue_name)
        cystTumorValue=tissueData(i,1);
    elseif contains(lower(tissue_name),'air')
        nonTissueValues=[nonTissueValues tissueData(i,1)];
    elseif contains(lower(tissue_name),'water')
        nonTissueValues=[nonTissueValues tissueData(i,1)];
    end
    
end

sizePLD=size(PLD);

%Creating 0/1 tumor tissue matrix 
tumorTissue= TissueMatrix == tumorValue;
if ~isempty(cystTumorValue)
     tumorTissue= tumorTissue + (TissueMatrix==cystTumorValue);
end
 
%Creating tumor PLD matrix by multiplying PLD-matrix and tumor tissue matrix
tumorMatrix=tumorTissue.*PLD;


%Creating 0/1 healthy tissue matrix excluding Tumor and multiplying it with
%PLD matrix
onlyTissue=ones(size(PLD));
for i=1:length(nonTissueValues)
           onlyTissue=onlyTissue.*(TissueMatrix~=nonTissueValues(i)); 
end

healthyPLD=PLD.*onlyTissue.*(tumorMatrix==0);


% ----- Sort and get PLDv1 value ------

% Number of elements in the tissue
[rowTissue, ~]=find(PLD);

% Reshape PLD matrix to a vector to be able to sort
PLD_vec=reshape(PLD,sizePLD(1).*sizePLD(2).*sizePLD(3),1);
sortPLD_vec1=sort(PLD_vec,'descend');
%Create correct length on healthy vector
sortPLD_vec=sortPLD_vec1(1:size(rowTissue));

% Number of elements in the healthy tissue
[rowHealthyTissue, ~]=find(healthyPLD);

% Reshape healthy PLD matrix to a vector to be able to sort
healthyPLD_vec=reshape(healthyPLD,sizePLD(1).*sizePLD(2).*sizePLD(3),1);
sortHealthyPLD_vec=sort(healthyPLD_vec,'descend');
%Create correct length on healthy vector
sortHealthyPLD_vec=sortHealthyPLD_vec(1:size(rowHealthyTissue));

% Calculate PLDv1 value
PLDv1=mean(sortHealthyPLD_vec(1:round(length(sortHealthyPLD_vec).*0.01)));

% Create sorted tumor vector
[rowTUM, ~]=find(tumorMatrix);
tumorVector=reshape(tumorMatrix,sizePLD(1).*sizePLD(2).*sizePLD(3),1);
sortTumorVector=sort(tumorVector,'descend');
tumorVector=sortTumorVector(1:length(rowTUM));
meanPLDtarget=mean(tumorVector);

HTQ=PLDv1/meanPLDtarget;
PLDmaxTum=tumorVector(1)/max(PLD(:));

% Tumor coverage
TC(1)=sum(tumorVector>0.25*sortPLD_vec(1))/length(tumorVector); % TC25
TC(2)=sum(tumorVector>0.5*sortPLD_vec(1))/length(tumorVector);  % TC50
TC(3)=sum(tumorVector>0.75*sortPLD_vec(1))/length(tumorVector); % TC75

% Mean PLD of nonzero elements (only model, not air outside)
PLD_0 = PLD~=0;
PLD_0_vec = zeros(sum(PLD_0(:)),1);
for i = 1:length(PLD_0_vec)
    PLD_0_vec(i) = sortPLD_vec(i);
end
meanPLD = mean(PLD_0_vec);
meanPLDnorm = mean(PLD_0_vec/max(PLD_0_vec)); %mean of normalized a, zero-elements are excluded

%display
disp(['HTQ is calculated to           : ' num2str(HTQ)])
disp(['PLDmaxTum is calculated to     : ' num2str(PLDmaxTum)])
disp(['meanPLDtarget is calculated to : ' num2str(meanPLDnorm)])
disp(['TC is calculated to            : ' num2str(TC)])

end
