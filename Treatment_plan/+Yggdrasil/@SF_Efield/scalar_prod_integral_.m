function a = scalar_prod_integral_(a, b)
%oct = SCALAR_PROD(a, b)
%   Calculates the scalar product between SF_Efields. This 
%   gives mixed term when calculating the power density.
    
    if ~Yggdrasil.Utils.Efield.are_Efields_compatible(a,b)
        error(['There is no physical reason to take the scalar product', ...
               'between two SF_Efields of different frequency or of ',...
               'different arrangements.']);
    end
    
    a = Yggdrasil.Octree.scalar_prod_integral(...
                                   Yggdrasil.Octree(a),...
                                   Yggdrasil.Octree(b));
end