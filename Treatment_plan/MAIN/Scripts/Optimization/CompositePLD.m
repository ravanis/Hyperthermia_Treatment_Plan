function [PLD_composite] = CompositePLD(PLD,l)
% SUBFUNCTION TO EF_OPTIMIZATION_MULTIPLE
%This function receives several PLD matrices and multiplies them pointwise
%and then converts the resulting matrix into an octree.
%PLD should be a matrix with four dimensions, where the first three
%describes the spatial coordinates and the fourth determines what 
%PLD. 

dim = size(PLD);
PLD_composite = ones(dim(1),dim(2),dim(3));
for i=1:l %l determines the amount of PLD-matrices you want to multiply. 
    PLD_composite = PLD_composite.*PLD(:,:,:,i);
end

end
