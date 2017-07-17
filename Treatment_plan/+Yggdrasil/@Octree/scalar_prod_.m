function a = scalar_prod_(a, b)
%oct = SCALAR_PROD_(a, b)
%   Calculates the scalar product between two vector fields. This 
%   function calculates "sum(conj(a).*b,4)" but uses quick c-code in the
%   case of a and b being octrees.
    if ~isa(a,'Yggdrasil.Octree')
        a = Yggdrasil.Octree(a);
    elseif ~isa(b,'Yggdrasil.Octree')
        b = Yggdrasil.Octree(b);
    end
    
    [a.data, a.adr, a.meta] = Yggdrasil.C.scalar_prod(...
                                  single(a.data), a.adr, a.meta, ...
                                  single(b.data), b.adr, b.meta);

end
