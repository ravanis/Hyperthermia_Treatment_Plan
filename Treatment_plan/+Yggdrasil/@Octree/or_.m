function c = or_(a,b)
%c = OR_(a,b)
%  or defined for octrees using de Morgan's law
    if ~isa(a, 'Yggdrasil.Octree') || ~isa(b, 'Yggdrasil.Octree')
        error('Or for octrees need both inputs to be octrees.');
    end
    
    c = ~((~a) & (~b));
end
