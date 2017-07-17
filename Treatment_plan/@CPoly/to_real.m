function [ out, mapp_realvar_to_CPoly, mapp_imvar_to_CPoly] = to_real( obj )
%[output] = TO_REAL( obj )
% Transforms the polynomial(Z) into polynomial(x+iy)

    mapp_realvar_to_CPoly = containers.Map('KeyType','int64','ValueType','int64');
    mapp_imvar_to_CPoly = containers.Map('KeyType','int64','ValueType','int64');
    
    out = CPoly(0);
    for i = 1:length(obj.monom)
        if isempty(obj.monom{i})
            out = out + obj.coefficients(i);
        else
            tmp = CPoly(obj.coefficients(i));
            monom = obj.monom{i};
            for j = 1:length(monom)
                [a,b,a_id,b_id,z_ind] = CtoR(monom(j));
                mapp_realvar_to_CPoly(a_id) = z_ind;
                mapp_imvar_to_CPoly(b_id) = z_ind;
                tmp = tmp*(a+b);
            end
            out = out + tmp;
        end
    end
    out = reduce(out);
end

function [r_var,i_var,r_ind,i_ind,z_ind] = CtoR(z_var_id)
%Transforms the complex varialbe Z into x+iy
    r_ind = abs(z_var_id)*2+10000;
    i_ind = abs(z_var_id)*2+10000 + 1;
    z_ind = abs(z_var_id);
    if z_var_id < 0 % Check if conjugated
        r_var = CPoly(1  , r_ind);
        i_var = CPoly(-1i, i_ind);    
    else
        r_var = CPoly(1,  r_ind);
        i_var = CPoly(1i, i_ind);  
    end

end