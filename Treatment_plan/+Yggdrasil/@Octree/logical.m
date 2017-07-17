function oct = logical(oct)
%oct = LOGICAL(oct)
%  logical for octrees, switches non-zeroes to one
    oct.data = oct.data ~= 0;
end


