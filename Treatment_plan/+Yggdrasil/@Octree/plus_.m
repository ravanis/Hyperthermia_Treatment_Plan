function a = plus_(a,b)
%oct = PLUS_(oct,b)
%  Overloads Matlabs + function for octrees. oct and b can be either octrees
%  or constants. The output oct is the addition of the two
%  inputs. This function does not reduce the amount of elements in the
%  octree even if it is possible after addition.

    if ~isa(a, 'Yggdrasil.Octree')
        tmp = a;
        a = b;
        b = tmp;
    end
    
    if Yggdrasil.Utils.isscalar(b)
        a.data = a.data + b;
        return;
    end
    
    if ~isequal(size(a),size(b))
       error('Both arguments need to be the same size.'); 
    end
    
    if ~isa(b, 'Yggdrasil.Octree')            
        a = a + Yggdrasil.Octree(b);
        return;
    end

    [a.data, a.adr, a.meta] = Yggdrasil.C.plus(...
                              single(a.data), a.adr, a.meta, ...
                              single(b.data), b.adr, b.meta);

end
