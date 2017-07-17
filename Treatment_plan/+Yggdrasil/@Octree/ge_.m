function output = ge_(a, b)
%output = GE_(a, b)
%  Equavivalent to matrix >= function. This will create a logical octree. 
%  Returns ones if a >= b otherwise returns zeroes.
    output = ~(a < b);
end
