function S = scalar_prod_(a,b)
%S = SCALAR_PROD_(a,b)
%   Takes the scalar prod between two MF_Efields or MF_Efields and
%   SF_Efield. In the case of MF vs MF the rhs MF is divided into SF.
%   If two E fields have different frequencies or arrangement their
%   their scalar prod is 0 octree.
    [a,b,mf_num] = Yggdrasil.MF_Efield.input_chk(a,b);
    if mf_num == 1
        k = b.hash();
        [key_exist, index] = a.E.is_key(k);
        if key_exist
            S = Yggdrasil.SF_Efield.scalar_prod_(a.E.values(index),b);
        else
            mat_size_b = b.meta.original_matrix_size;
            S = Yggdrasil.Octree.zeros(mat_size_b);
        end
        return;
    end

    S = Yggdrasil.MF_Efield.scalar_prod_(a, b.E.values(1));
    for i = 2:length(b.E)
        S = S + Yggdrasil.MF_Efield.scalar_prod_(a, b.E.values(i));
    end
end

