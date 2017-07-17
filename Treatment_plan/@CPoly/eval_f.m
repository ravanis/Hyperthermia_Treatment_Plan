function [ output ] = eval_f(X, poly, mappZ2r, mappZ2i, mapp2fvar )
%EVAL_F Summary of this function goes here
%   Detailed explanation goes here
    output = 0;

    for i = 1:length(poly.monom)
        monom = poly.monom{i};
        product = 1;
        for j = 1:length(monom)
            var = monom(j);
            product = product * eval_Z(var);
        end

        output = output + real(product*poly.coefficients(i));
    end

    function [Z] = eval_Z(z_id)
        Z = 0;
        r_id = mappZ2r(abs(z_id));
        i_id = mappZ2i(abs(z_id));
        if isKey(mapp2fvar,r_id)
            Z = Z + X(mapp2fvar(r_id));
        end
        if isKey(mapp2fvar,i_id)
            Z = Z + 1i*X(mapp2fvar(i_id));
        end
        
        if z_id<0
            Z = conj(Z);
        end
    end


end

