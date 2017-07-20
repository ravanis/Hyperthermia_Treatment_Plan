function [PLD_ratio] = CreateOptimalPLD(x,PLD)
% SUBFUNCTION TO EF_OPTIMIZATION_MULTIPLE
%Let x be a vector of positive real numbers which sum up to one.
%Let every PLD exist in the first, second and third dimension, and let 
%different PLD be seperated in the fourth dimension. 

dim = size(PLD);
PLD_ratio = zeros(dim(1),dim(2),dim(3));

for i=1:length(dim(4))
    PLD_ratio = PLD_ratio + x(i)*PLD(:,:,:,i);
end

end