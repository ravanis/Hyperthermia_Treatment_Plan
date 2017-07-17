function a = mtimes_(a,b)
%oct = MTIMES_(a, b)
%  Overload matlabs mtimes (*), only works for octree*constant
    if ~isa(a, 'Yggdrasil.Octree')
        tmp = a;
        a = b;
        b = tmp;
    end
    if ~Yggdrasil.Utils.isscalar(b)
        error('mtimes (*) only defined for octree*scalar')
    end
    a.data = b*a.data;
end
