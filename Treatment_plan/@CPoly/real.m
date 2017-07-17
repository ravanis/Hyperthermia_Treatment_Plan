function [ out ] = real( obj )
% Returns the real value part of the polynomial
out = 1/2*(obj + conj(obj));

end

