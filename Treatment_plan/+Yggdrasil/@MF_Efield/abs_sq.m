function [ P ] = abs_sq( mf_obj )
%[ oct ] = ABS_SQ( mf_obj )
%   Calculates the PLD(power loss density) from a MF_Efield object

P = abs_sq(mf_obj.E.values(1));

for i = 2:length(mf_obj.E)
    P = P + abs_sq(mf_obj.E.values(i));
end

end

