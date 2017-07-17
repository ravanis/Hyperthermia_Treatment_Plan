function oct = mrdivide_(oct,b)
%oct = MRDIVIDE_(oct,b)
%  Overloads Matlabs mrdivide for octrees, can olny be used to divide
%  octrees with scalars
    if ~Yggdrasil.Utils.isscalar(b)
        error('mrdivide (/) only defined for octree/scalar')
    end
    oct = oct*(1/b);
end
