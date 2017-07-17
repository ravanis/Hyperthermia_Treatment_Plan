function [ output ] = eval_f_weighted(X, poly, X_w, poly_w, mappZ2r, mappZ2i, mapp2fvar)

%function [ output ] = eval_f(X, poly, old_poly, mappZ2r, mappZ2i, mapp2fvar)
%We also need monom, var and eval_Z for the old polynmoial in the for loops below line 9.
%EVAL_F Summary of this function goes here
%   
    output = 0;

    for i = 1:length(poly.monom)
        monom = poly.monom{i};
        monom_w = poly_w.monom{i};
        product = 1;
        for j = 1:length(monom)
            var = monom(j);
            var_w = monom_w(j);
            product = product * eval_Z(var);
            product_w = product * eval_Z_w(var);
        end
        
        output = output + real(product*poly.coefficients(i))*real(product*old_poly.coefficients(i));
        
    end

    function [Z] = eval_Z(z_id)
        Z = 0;
        r_id = mappZ2r(abs(z_id));
        i_id = mappZ2i(abs(z_id));
        if isKey(mapp2fvar,r_id) %If it is an old polynomial, then skip line 27
            Z = Z + X(mapp2fvar(r_id));
        end
        if isKey(mapp2fvar,i_id) %If it is an old polynomial, then skip line 30, or create a new function
            Z = Z + 1i*X(mapp2fvar(i_id));
        end
        
        if z_id<0
            Z = conj(Z);
        end
    end

    function [Z] = eval_Z_w(z_id)
        Z = 0;
        r_id = mappZ2r(abs(z_id));
        i_id = mappZ2i(abs(z_id));
        if isKey(mapp2fvar,r_id) %If it is an old polynomial, then skip line 27
            Z = Z + X_w(mapp2fvar(r_id));
        end
        if isKey(mapp2fvar,i_id) %If it is an old polynomial, then skip line 30, or create a new function
            Z = Z + 1i*X_w(mapp2fvar(i_id));
        end
        if z_id<0
            Z = conj(Z);
        end
    end

end

