function a = uminus(a)
%a = UMINUS(a)
%   This function negates the coefficient values of input polynomial a and
%   then returns it. 
a.coefficients = -a.coefficients;
end

