function [ comp ] = are_Efields_compatible(a,b)
%[ comp ] = are_Efields_compatible(a,b)
%   Checks if two SF_E-fields are physically compatible with eachother.
%   That is if they are able to interfere with eachother.
%   This means that the their frequency are the same and that their arrangement
%   are the same. 

    if ~isa(a,'Yggdrasil.SF_Efield')
        error('First input argument is not a SF_Efield.')
    end
    
    if ~isa(b,'Yggdrasil.SF_Efield')
        error('Second input argument is not a SF_Efield.')
    end
    
    if a.frequency ~= b.frequency
        comp = false;
        return
    end
    
    if a.arrangement ~= b.arrangement
        comp = false;
        return
    end
    comp = true;
end

