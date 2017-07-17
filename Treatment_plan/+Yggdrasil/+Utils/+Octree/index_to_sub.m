% Returns the i,j,k subscripts corresponding to the single index of a 
% 2x2x2 matrix
function [output] = index_to_sub(index)
    if index == 1
        output = [0 0 0];
    elseif index == 2
        output = [1 0 0];
    elseif index == 3
        output = [0 1 0];
    elseif index == 4
        output = [1 1 0];
    elseif index == 5
        output = [0 0 1];
    elseif index == 6
        output = [1 0 1];
    elseif index == 7
        output = [0 1 1];
    else
        output = [1 1 1];
    end
end