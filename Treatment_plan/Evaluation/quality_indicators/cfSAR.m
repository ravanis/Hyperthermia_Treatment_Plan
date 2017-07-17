% This function calculates the Specific Absorption Rate (SAR) matrix from
% the provided PLD matrix. The function uses cubic filtering so each SAR element
% is a mean over a 10x10x10 box where each element is PLD/density.

% --- INPUT VARIABLES ---
% PLDmatrix - input Power Loss Density matrix calculated by CST or Matlab.
% tissueMatrix - model tissue matrix.
% tissue_filepath - absolute filepath to the tissue file containing tissue properties

function SARmatrix=cfSAR(PLDmatrix,tissueMatrix,tissue_filepath)

s=size(PLDmatrix);
density_matrix=zeros(s);


cube_size=10;

[tissueData, ~]=importTissueFile(tissue_filepath);
for i=1:length(tissueData)
    density_matrix=density_matrix+(tissueMatrix==tissueData(i,1))./(tissueData(i,5));
end

SARmatrix=PLDmatrix.*density_matrix; 

for i=cube_size/2:s(1)-cube_size/2
    disp(['Calculating slice ' int2str(i) ' of ' int2str(s(1)) ]) 
    for j=cube_size/2:s(2)-cube_size/2
        for k=cube_size/2:s(3)-cube_size/2
            
            mask_matrix=density_matrix(i+1-cube_size/2:i+cube_size/2, j+1-cube_size/2:j+cube_size/2, k+1-cube_size/2:k+cube_size/2);
            tempMatrix=PLDmatrix(i+1-cube_size/2:i+cube_size/2, j+1-cube_size/2:j+cube_size/2, k+1-cube_size/2:k+cube_size/2);
            SARmatrix(i,j,k)=mean(mean(mean(tempMatrix.*mask_matrix)));
        
        end
    end
end




















end