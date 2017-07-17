function oct = power(oct,b)
%oct = POWER(oct,b)
%  Overloads the .^b operator. Basically elementwise power on octree data
%  INPUT:
%  oct - An octree
%  b   - A nummeric constant

    if Yggdrasil.Utils.isscalar(b)
        oct.data = oct.data .^ b;
    else
        error('Power is only defined for octree .^ scalar.')
    end
end
