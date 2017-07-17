%This class handles complex polynomials of the type 
%2*c_1*conj(c_2) + 4.2i*c_1*c_2.
%It is designed to speed up and to simplify creation of large polynomials.
classdef CPoly
   properties
      monom
      coefficients
   end
   methods
      %Constructor
      function obj = CPoly(coefficient, variables)
         if nargin == 0
            error('Too few input arguments');
         end
         if ~(nargin == 1 | nargin == 2) 
            error('Too many input arguments');
         end
         
         if ~isnumeric(coefficient)
             error('Value must be numeric or defining a monomial.');
         end
         
         if nargin == 1
               obj.monom = {[]};
               obj.coefficients = coefficient;
         elseif nargin == 2
               if ~isnumeric(variables)
                    error('Variables must be given as a integer.');
               end
               
               if length(variables) ~= numel(variables)
                  error('The integer vector defining the monomial needs to be 1 dimensional.'); 
               end
               
               if length(variables) ~= size(variables,1)
                  error('The integer vector defining the monomial needs to be a column vector.'); 
               end
               
               if ~all(round(variables)==variables)
                  error('The vector defining the monomial needs to be an integer vector.'); 
               end
               
               if any(variables == 0)
                  error('The vector defining the monomial can not contain any zeroes.'); 
               end
               
               obj.monom = {sort(int64(variables),'ascend')};
               obj.coefficients = coefficient;
         end
      end
      output = plus(a,b);
      output = minus(a,b);
      output = uplus(a,b);
      output = uminus(a,b);
      output = mtimes(a,b);
      output = mpower(a,b);
      output = conj(a);
      output = reduce(a);
      output = eq(a,b);
      output = ne(a,b);
      output = isconst(a);
      output = real(a);
      output = min_ratio(a,b)
      deriv = derivative(real_poly, id)
      
   end
   methods (Static)
       output = unique_index(cell_of_vectors);
       output = eval_f(X, poly, mappZ2r, mappZ2i, mapp2fvar )
       [realZ, imagZ] = optimize_ratio(numer_CPoly,denom_CPoly)
       [mapp_CPolyvar_to_fvar, mapp_fvar_to_CPolyvar, n] ...
    = real_to_fmap(cell_of_real_poly)
   end
   methods
       output = evaluate(obj, vektor_of_z);
       [mpol_P1,mpol_P2,x,    ...
           map_cpoly_to_mpol, ...
           map_mpol_to_cpoly] = to_mpol(cpoly1, cpoly2)
       [out, mapp_realvar_to_CPoly, mapp_imvar_to_CPoly] = to_real(obj)
   end
       
end