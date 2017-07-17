function a = weight_(a,w)
%a = WEIGHT_(a,w)
%   weight operation on MF_Efield by looping over all SF_Efield
    if ~isa(a, 'Yggdrasil.MF_Efield')
        error('First argument must be MF_Efield.');
    end

    for i = 1:length(a.E)
        a.E.values(i) = a.E.values(i).weight(w);
    end
end
