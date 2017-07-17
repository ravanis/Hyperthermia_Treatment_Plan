function a = plus(a,b)
%a = PLUS(a,b)
%   Defines addition for CPoly

if isa(a,'CPoly')
    if isa(b,'CPoly')
        a.coefficients = [a.coefficients(:); b.coefficients(:)];
        a.monom = {a.monom{:}, b.monom{:}};
    else %Poly plus constant
        a.coefficients(end+1,1) = b;
        a.monom{end+1} = [];
    end
else
    if isa(b,'CPoly') %If constant plus poly
        tmp = a;
        a = b;
        a.coefficients(end+1,1) = tmp;
        a.monom{end+1} = [];
    else %Constant plus constant
        a = a+b;
    end
end


end

