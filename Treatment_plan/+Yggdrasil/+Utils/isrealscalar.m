function [ is_scalar ] = isrealscalar( scalar )
%ISREALSCALAR(a)
%  Tests if scalar is a scalar. Used because Matlab.
    is_scalar = isnumeric(scalar) && isscalar(scalar) && isreal(scalar);
end

