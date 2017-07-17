function output = any(oct)
%output = ANY(oct)
%  Returns 1 if there is one or more non-zero elements in the octrees data
    output = any(oct.data(:) ~= 0);
end
