% output = ABS_SQ(input)
% A function that can handle both matrices and octrees.
% It calculates the vectorial sum(abs(...)^2,4) operation.
function [ output ] = abs_sq( input )
    if isa(input, 'Yggdrasil.Octree')
        output = input.abs_sq();
        return;
    end
    output = sum(input.*conj(input),4);
end

