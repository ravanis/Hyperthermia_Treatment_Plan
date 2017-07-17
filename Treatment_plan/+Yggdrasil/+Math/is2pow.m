%[ is2, N ] = IS2POW( numb )
% Checks if input is a power of 2
% OUTPUT:
%    is2 - is numb a power of 2
%    N   - the smallest number N: 2^N >= numb
function [ is2, N ] = is2pow( numb )
    is2 = false;
    N = ceil(log2(numb));
    if 2^N == numb
        is2 = true;
        return;
    end

end

