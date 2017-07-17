function c = and(a,b)
%c = AND(a,b)
%  Defines and for combinations between octrees and matrices
    if ~isa(a, 'Yggdrasil.Octree') || ~isa(b, 'Yggdrasil.Octree')
        error('Or for octrees need both inputs to be octrees.');
    end
    
    c = logical(a .* b);
end
