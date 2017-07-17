function [a] = mtimes_(a, b)
%[a] = MTIMES_(a, b) 
%   Overloads * for SF_Efield
    if ~isa(a,'Yggdrasil.SF_Efield')
        tmp = a;
        a = b;
        b = tmp;
    end
    
    if ~Yggdrasil.Utils.isscalar(b)
        error('Can only multiply SF_Efield with a numeric scalar.');
    end
    
    if a.is_content_local
        a = mtimes_@Yggdrasil.Octree(a,b);
    end
    a.C = a.C * b;
end

