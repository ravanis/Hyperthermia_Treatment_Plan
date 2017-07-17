function a = conj(a)
%a = CONJ(a)
%   Conjugates the whole polynomial

    %Conjugates the monomials by flipping and changing sign
    for i = 1:length(a.monom)
        a.monom{i} = -flipud(a.monom{i});
    end
    
    %And the coefficients can be conjugated by 
    a.coefficients = conj(a.coefficients);
    
end

