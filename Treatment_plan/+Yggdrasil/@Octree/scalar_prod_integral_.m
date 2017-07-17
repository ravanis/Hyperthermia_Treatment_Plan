function output = scalar_prod_integral_(a, b)
%output = SCALAR_PROD_INTEGRAL_(a, b)
%  Scalar product and integral built together.
    if ~isa(a,'Yggdrasil.Octree')
        a = Yggdrasil.Octree(a);
    elseif ~isa(b,'Yggdrasil.Octree')
        b = Yggdrasil.Octree(b);
    end
    [output] = Yggdrasil.C.scalar_prod_integral(...
                                  single(a.data), a.adr, a.meta, ...
                                  single(b.data), b.adr, b.meta);
end
