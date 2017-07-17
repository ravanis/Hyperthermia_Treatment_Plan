function a = plus_(a,b)
%a = plus_(a,b)
%   Plus defined for MF + SF or MF + MF. Because Yggmap have plus defined
%   this operation is defined using addition of maps.
    [a,b,mf] = Yggdrasil.MF_Efield.input_chk(a,b);
    if mf == 1
        k = b.hash();
        a.E = a.E + {k,b};
        return
    end
    a.E = a.E + b.E;
end

