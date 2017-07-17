function [ is_scalar ] = isscalar( scalar )
%ISSCALAR(a)
%  Tests if scalar is a scalar. Used because Matlab.
    is_scalar = isnumeric(scalar) && isscalar(scalar);
end

