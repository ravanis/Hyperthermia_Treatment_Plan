function [x,y,mf_num] = input_chk(a,b)
%[x,y,mf_num] = INPUT_CHK(a,b)
%   Handles input checks for commutitive operators. The main use is
%   ensuring that a is a MF_Efield, the second use is count the number of
%   MF_Efields, this is used to differentiate between MF vs MF or SF vs MF.
    if isnumeric(a) || isnumeric(b)
        error('Matrices is not supported.');
    end

    if strcmp(class(a), 'Yggdrasil.Octree') || ...
       strcmp(class(b), 'Yggdrasil.Octree')
       error('Plain octrees are not allowed.');
    end

    if ~isa(a,'Yggdrasil.MF_Efield')
        % Switch order, [MF,SF]
        x = b;
        y = a;
        mf_num = 1;
        return
    end

    if ~isa(b,'Yggdrasil.MF_Efield')
        % Correct order, [MF,SF]
        x = a;
        y = b;
        mf_num = 1;
        return
    end

    % [MF,MF]
    x = a;
    y = b;
    mf_num = 2;
end

