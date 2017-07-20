function [y] = HTQ_multiple(x,PLD_matrices)
% SUBFUNCTION TO EF_OPTIMIZATION_MULTIPLE
%Let PLD_matrices be the size of the tissuematrix, and then add several
%frequencies in the fourth dimension, e.g., 250x250x250x10, if 10 different
%frequencies is desired.
%This function calculates the resulting HTQ when we let all the elements in
%x sum up to 1.

dim = size(PLD_matrices);
y = 0;
for i=1:length(dim(4))
    y = y + x(i)*PLD_matrices(:,:,:,i);
end

end