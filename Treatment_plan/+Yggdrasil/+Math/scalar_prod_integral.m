function output = scalar_prod_integral(a, b)
%output = SCALAR_PROD_INTEGRAL(a,b)
%   Is equvivalent to integral(scalar_prod(a,b)). But the process is speed
%   up by C-code.
    if isa(a,'Yggdrasil.AbstractOctreePriority') || isa(b,'Yggdrasil.AbstractOctreePriority') 
        a_handle = @a.scalar_prod_integral_;
        b_handle = @b.scalar_prod_integral_;
        output = Yggdrasil.AbstractOctreePriority.prio(a,b,a_handle,b_handle);
        return;
    end
    output = Yggdrasil.Math.integral(...
             Yggdrasil.Math.scalar_prod(a, b));
end
