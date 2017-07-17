function index = unique_index(monom)
%index = UNIQUE_INDEX(monom)
%   Creates an unique index for column vector in cell_of_vectors.

%Default val
maximum_length = 0;
maximum_value = 0;

for i = 1:length(monom)
    %Find the longest row-vector
    maximum_length = max(maximum_length,length(monom{i}));
   
    %Find the highest index used in a monomial
    maximum_value = max([maximum_value; abs(monom{i})]); 
    
end

%Compare the biggest number used in as an index
if double(maximum_length)*log2(double(maximum_value)) > 62
    error('Too large polynomial to uniquely describe.')
end

%Calculate the indecies
index = zeros(size(monom));
for i = 1:length(monom)
    if isempty(monom{i})
        continue;
    end
    for j = 1:length(monom{i})
        index(i) = index(i) + monom{i}(j)*maximum_value^(j-1);
    end
end

end
