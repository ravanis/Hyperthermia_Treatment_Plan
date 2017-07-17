function a = weight_(a, w)
%oct = WEIGHT_(a, w);
%    Weights and vector field a with the weight w. The weight can be a
%    scalar or a scalar field.
    
    if Yggdrasil.Utils.isscalar(w)
       a = a * w; 
       return;
    end
    
    if ~isa(a,'Yggdrasil.Octree')
        a = Yggdrasil.Octree(a);
    end
    if ~isa(w,'Yggdrasil.Octree')
        w = Yggdrasil.Octree(w);
    end
    
   [a.data, a.adr, a.meta] = Yggdrasil.C.weight(...
                          single(a.data), a.adr, a.meta,...
                          single(w.data), w.adr, w.meta);
end
