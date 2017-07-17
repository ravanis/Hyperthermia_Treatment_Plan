function S = scalar_prod_integral_(a,b)
%S = SCALAR_PROD_INTEGRAL_(a,b)
%   Takes the scalar prod integral between two MF_Efields or MF_Efields and
%   SF_Efield. In the case of MF vs MF the rhs MF is divided into SF.
%   If two E fields have different frequencies or arrangement their
%   their scalar prod integral is scalar 0.
    [a,b,mf_num] = Yggdrasil.MF_Efield.input_chk(a,b);

    if mf_num == 1
        k = b.hash();
        [key_exist, index] = a.E.iskey(k);
        if key_exist
            S = a.E.values(index).scalar_prod_integral_(b);
        else
            S = 0;
        end
        return;
    end

    S = a.scalar_prod_integral_(b.values(1));
    for i = 2:length(b)
        S = S + a.scalar_prod_integral_(b.values(i));
    end
end