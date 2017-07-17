function a = scalar_prod(a,b)
%oct = SCALAR_PROD(a, b)
%   Calculates the scalar product between two vector fields. This 
%   function calculates "sum(conj(a).*b,4)" but uses quick c-code in the
%   case of a and b being octrees.
    if isa(a,'Yggdrasil.AbstractOctreePriority') || isa(b,'Yggdrasil.AbstractOctreePriority')
        a_handle = @a.scalar_prod_;
        b_handle = @b.scalar_prod_;
        a = Yggdrasil.AbstractOctreePriority.prio(a,b,a_handle,b_handle);
        return;
    end

%  Try to scalar_prod by using basic operations
    a = sum(conj(a).*b,4);
end
