function [a] = plus_(a,b)
%Adds two SF_Efields

    if ~isa(a, 'Yggdrasil.SF_Efield') || ~isa(b, 'Yggdrasil.SF_Efield')
        error('Can single frequency Efields only add with itself?')
    end
    
    % If they are orthogonal time wise
    if a.frequency ~= b.frequency || a.arrangement ~= b.arrangement
        mf_obj = Yggdrasil.MF_Efield(); %tillagt
        
        t = mf_obj + a;
        a = t + b;
        return;
    end
    
    a = plus_@Yggdrasil.Octree(a,b);
    a.C = a.C + b.C;
end

