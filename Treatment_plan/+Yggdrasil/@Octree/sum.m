function [ oct ] = sum(oct, const)
%[ oct ] = SUM(oct, const)
%  This function is the octree equivalent to matrix summation along
%  the fourth dimension. The function should be called as
%  SUM(oct, 4), all other constants const are invalid.
    if nargin ~= 2
       error(['Invalid number of arguments. This function is equivalent ' ...
           'to matrix summation in the fourth dimension, and because of'...
           ' this needs to be called as "sum(oct, 4)".']) 
    end

    if const ~= 4
       error(['Invalid input. This function is equivalent ' ...
           'to matrix summation in the fourth dimension, and because of'...
           ' this needs to be called as "sum(oct, 4)".'])
    end

    oct.data = sum(oct.data,1);
end

