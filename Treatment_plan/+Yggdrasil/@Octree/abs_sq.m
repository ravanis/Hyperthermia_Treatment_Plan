function [ self ] = abs_sq( self )
%self = ABS_SQ(self)
%  A function that can handle both matrices and octrees.
%  It calculates the vectorial sum(abs(...)^2,4) operation.
    self.data = sum(real(self.data).^2,1) + sum(imag(self.data).^2,1);
    self.meta.eps = 2*self.meta.eps;
end

