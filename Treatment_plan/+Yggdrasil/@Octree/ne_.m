function output = ne_(a, b)
%output = NE_(a, b)
%  Equavivalent to matrix ~= function. This will create a logical octree. 
%  Returns 1 if the octrees have nonequal data values otherwise returns 0.
    if ~isa(a, 'Yggdrasil.Octree')
        tmp = a;
        a = b;
        b = tmp;
    end
    output = logical(a-b);
end
