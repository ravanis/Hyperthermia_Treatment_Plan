function output = mtimes_(a,b)
%output = MTIMES_(a,b)
%   Defines scalar * MF_Efield
    if Yggdrasil.Utils.isscalar(b)
        output = a;
        output.E = a.E*b;
    elseif Yggdrasil.Utils.isscalar(a)
        output = b;
        output.E = b.E*a;
    else
        error('Multiplication is only defined for MF_Efield * scalar.')
    end
end

