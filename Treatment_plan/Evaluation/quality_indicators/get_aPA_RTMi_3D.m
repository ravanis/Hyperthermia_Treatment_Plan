% Returns aPA and RTMi

function [aPa, RTMi] = get_aPA_RTMi_3D (pldMatrix,tissueMatrix,nbrOfMaxValues, tissue_filepath)

% ---INPUT PARAMETERS---
% pldMatrix - Power loss density matrix returned from
% exportPLD/getInterpMatrix
%
% tissueMatrix - Tissue matrix (must be same size as pldMatrix)
%
% nbrOfMaxValues - number of peak pld values you want to exclude from your
% calculation. Standard: 10-20
%
% tumorTissueValues - file path to the tissue file

% --- Import tissue file and find indices ---
[tissueData, tissue_names]=importTissueFile(tissue_filepath);
tumorIndex=find(strcmp('Tumor',tissue_names));
cystTumorIndex=find(strcmp('Cyst-Tumor',tissue_names));
tumorValue=tissueData(tumorIndex,1);
cystTumorValue=tissueData(cystTumorIndex,1);
tumorTissueValues= tumorValue;
if ~isempty(cystTumorValue)
    tumorTissueValues=[tumorValue, cystTumorValue];
end

airIndex=find(~cellfun('isempty',(strfind(lower(tissue_names),'air'))));
waterIndex=find(~cellfun('isempty',(strfind(lower(tissue_names),'water'))));
exteriorIndex=find(~cellfun('isempty',(strfind(lower(tissue_names),'exterior'))));
nonTissueIndeces=[airIndex;waterIndex;exteriorIndex];
nonTissueValues=tissueData(nonTissueIndeces,1);


% Create tumor =0/1 matrix
size_pldMatrix = size(pldMatrix,1)*size(pldMatrix,2)*size(pldMatrix,3);
tumor=zeros(size(tissueMatrix));
for i=1:length(tumorTissueValues)
    tumor = tumor + (tissueMatrix == tumorTissueValues(i));
end
tumorLength = length(find(tumor));

% Create healthy tissue 0/1 matrix
onlyTissue=ones(size(pldMatrix));
for i=1:length(nonTissueIndeces)
           onlyTissue=onlyTissue.*(tissueMatrix~=nonTissueValues(i)); 
end
healthyTissue=onlyTissue.*(tumor==0);
    
healthyLength = length(find(healthyTissue));

pldTumor = pldMatrix.*tumor;
pldTumor=reshape(pldTumor,size_pldMatrix,1);
pldTumor = sort(pldTumor,'descend');
pldTumor = pldTumor(1:tumorLength);

pldHealthy = pldMatrix.*healthyTissue;
pldHealthy = reshape(pldHealthy,size_pldMatrix,1);
pldHealthy = sort(pldHealthy,'descend');
pldHealthy = pldHealthy(nbrOfMaxValues+1:healthyLength);

% (sum(pldTumor) / tumorLength);
% (sum(pldHealthy) / length(pldHealthy));
aPa = (sum(pldTumor) / tumorLength) / (sum(pldHealthy) / length(pldHealthy));

PA_1 = pldHealthy(round(length(pldHealthy)*0.01));
PA_50 = median(pldTumor);
RTMi = PA_1/PA_50;

end