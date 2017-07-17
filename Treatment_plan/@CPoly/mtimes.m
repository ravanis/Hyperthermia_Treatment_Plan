function a = mtimes(a,b)
%a = MTIMES(a,b)
%   Defines multiplication for CPoly

if isa(a,'CPoly')
    if isa(b,'CPoly')
        c = CPoly(0); %Create output variable
        %Using forloops to handle the product of every pair of monomials
        c.monom = cell(1,size(a.monom,1)*size(b.monom,1));
        c.coefficients = zeros(size(c.monom));
        counter = 1;
        for i = 1:size(a.coefficients,1)
            for j = 1:size(b.coefficients,1)
                c.coefficients(counter,1) = ...
                    a.coefficients(i)*b.coefficients(j);
                c.monom{counter} = sort([a.monom{i} ; b.monom{j}],'ascend');
                counter = counter + 1;
            end 
        end
        a = c;
    else %Poly times constant
        a.coefficients = a.coefficients * b;
    end
else
    if isa(b,'CPoly') %If constant times poly
        tmp = a;
        a = b;
        a.coefficients = a.coefficients * tmp;
    else %Constant times constant
        a = a*b;
    end
end


end

