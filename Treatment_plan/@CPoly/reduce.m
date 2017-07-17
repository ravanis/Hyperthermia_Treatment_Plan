function b = reduce(in_a)
%b = REDUCE(a)
%   Reduces a polynomial by sorting and then adding together coefficients
%   of the same monomials. This creates a unique representation of every 
%   polynomial which can be used to check if two polynomials are equal.

% Build onto output
b = CPoly(0);

% Remove zero elements
a = removeZeroes(in_a);

% If nothing is left
if isempty(a.monom)
    b = in_a;
    return
end

% If everything got removed
if isempty(a)
   return; %Return default value
end

[~,order] = sort(CPoly.unique_index(a.monom),'ascend');
a.monom = a.monom(order);
a.coefficients = a.coefficients(order);

% Allocate memory
b.monom = cell(size(a.monom));
b.coefficients = zeros(size(a.coefficients));

% Go through a and find non-unique monomials
% Combine and save unique monomials in b
i = 1;
lastMon = a.monom{1}; % Last monomial found
b.monom{i} = lastMon; 
for j = 1:length(a.coefficients)
    if isequal(lastMon, a.monom{j})% Non-unique monomial found
        b.coefficients(i) = b.coefficients(i) + a.coefficients(j);
    else
        i = i+1;
        lastMon = a.monom{j};
        b.monom{i} = lastMon;
        b.coefficients(i) = a.coefficients(j);
    end
end

% Remove unsed memory-spaces
b.monom(i+1:end) = [];
b.coefficients(i+1:end) = [];

% The output could have produced zeros
b = removeZeroes(b);

if isempty(b)
    b = CPoly(0);
end

end

function [a] = removeZeroes(a)
    % Remove 0 coefficients, iff b isn't just a constant
    remove_indecies = abs(a.coefficients) < 10^-10;

    a.coefficients(remove_indecies) = [];
    a.monom(remove_indecies) = [];
end
