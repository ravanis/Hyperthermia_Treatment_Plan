function [ deriv ] = derivative( real_poly, id )
deriv = CPoly(0);
for i = 1:length(real_poly.monom)
    monom = real_poly.monom{i};
    coeff = real_poly.coefficients(i);
    for j = 1:length(monom)
        if monom(j) == id
            deriv = deriv + CPoly(coeff, [monom(1:i-1); monom(i+1:end)]);
        end
    end
end
deriv = reduce(deriv);
end

