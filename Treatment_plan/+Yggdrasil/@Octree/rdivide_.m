function oct = rdivide_(a,b)
%oct = RDIVIDE_(a,b)
%  Defines ./ for octrees.
    if Yggdrasil.Utils.isscalar(a)
        % scalar / octree
        oct = b;
        oct.data = a./oct.data;
    else
        % non-scalar / something
        oct = a.*(1./b);
    end
end
