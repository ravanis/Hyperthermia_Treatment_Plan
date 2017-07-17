function output = all(oct)
%output = ALL(oct)
%  Implements all for octrees
    output = all(oct.data(:) ~= 0);
end
