function equal = eq(a,b)
%equal = EQ(a,b)
%   Checks if two polynomials are the same

if ~isa(a,'CPoly') | ~isa(b,'CPoly')
    error('CPoly can only be compared with CPoly.');
end

a = reduce(a);
b = reduce(b);

equal = isequal(a,b);

end

