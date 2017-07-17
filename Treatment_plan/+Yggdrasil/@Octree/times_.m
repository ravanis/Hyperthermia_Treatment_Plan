function a = times_(a,b)
%oct = TIMES_(oct,b)
%  Does .* operation on octree and octree/scalar/matrix.
%  In the case of octree.*octree or octree.*matrix their 
%  sizes need to be the same.

    % Ensure a is octree
    if ~isa(a, 'Yggdrasil.Octree')
        tmp = a;
        a = b;
        b = tmp;
    end
    
    if Yggdrasil.Utils.isscalar(b)
        a.data = b .* a.data;
        return;
    end
    
    if ~isequal(size(a),size(b))
       error('Both arguments need to be the same size.'); 
    end
    
    if ~isa(b, 'Yggdrasil.Octree')            
        a = a .* Yggdrasil.Octree(b);
        return;
    end

    % Only case left is both a and b being octrees
    [a.data, a.adr, a.meta] = Yggdrasil.C.times(...
                                  single(a.data), a.adr, a.meta, ...
                                  single(b.data), b.adr, b.meta);
end
