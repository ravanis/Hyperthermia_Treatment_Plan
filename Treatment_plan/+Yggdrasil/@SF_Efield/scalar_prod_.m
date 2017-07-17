function a = scalar_prod_(a, b)
%oct = SCALAR_PROD(a, b)
%   Calculates the scalar product between SF_Efields. This 
%   gives mixed term when calculating the power density.
    
    if ~Yggdrasil.Utils.Efield.are_Efields_compatible(a,b)
        if size(a)~=size(b)
            error('Can''t take scalar product between two different sized E-fields.')
        end
        n1 = size(a,1);
        n2 = size(a,2);
        n3 = size(a,3);
        a = Yggdrasil.Octree.zeros([n1,n2,n3]);
        return
        % You could reason that
        % error(['There is no physical reason to take the scalar product', ...
        %       'between two SF_Efields of different frequency or of ',...
        %       'different arrangements.']);
    end
    
    a = Yggdrasil.Octree.scalar_prod_(...
                                   Yggdrasil.Octree(a),...
                                   Yggdrasil.Octree(b));
end