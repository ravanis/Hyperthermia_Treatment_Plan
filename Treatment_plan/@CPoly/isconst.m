function is_const = isconst(a) 
%is_const = ISCONST(a) 
%   Checks if a is a constant. Only works on reduced shapes

is_const = false;

if length(a.monom) == 1
    if isequal(a.monom{1},[])
       is_const = true;
    end
end

end

