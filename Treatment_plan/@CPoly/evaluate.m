function val = evaluate(poly, z_vec)
%val = EVALUATE(poly, z_vec)
% DEPRECATED,
%   Evaluates the polynomial poly with the given Z-values from z_vec. If the
%   number of Z-values  is lower then the Z-values in the polynomial a error
%   is thrown. 

% Default values
val_vec = zeros(1, length(poly.monom));

% For every monomial in the polynomial 
for i = 1:length(poly.monom)
    product = 1;
    % If Z-values not given in the input is to be used throw an error
    if max(abs(poly.monom{i})) > length(z_vec)
        error('Not enough Z-values in the input.');
    end
    % If the monomial is a constant use the default value 1
    if isempty(poly.monom{i})
        val_vec(i) = 1;
    else
        % Otherwise make a product of all the Z-values where conjugates are
        % treated separately
        for j = poly.monom{i}.'
            if j < 0
                product = product * conj(z_vec(-j));        
            else
                product = product * z_vec(j);
            end
        end
        val_vec(i) = product;
    end
end
% Multiplicate the calues from the monoms with their respective
% coefficients
val =  val_vec * poly.coefficients;

end
