function a = weight(a, w)
%output = WEIGHT(a, w)
%    Weights and vector field a with the weight w. The weight can be a
%    scalar or a scalar field.
    if isa(a, 'Yggdrasil.AbstractOctreePriority') || isa(w, 'Yggdrasil.AbstractOctreePriority')
        a_handle = @a.weight_;
        w_handle = @w.weight_;
        a = Yggdrasil.AbstractOctreePriority.prio(a,w,a_handle,w_handle);
        return;
    end

    if ~isnumeric(a) || ~isnumeric(w)
        error(['Can not weight ' class(a) ' with ' class(w) '.'])
    end

    %Both a and w are matrices
    if Yggdrasil.Utils.isscalar(w)
       a = a * w; 
       return;
    end

    if size(w,4) ~= 1
       error('The weight must be a scalar field.') 
    end

    if any([size(a,1) ~= size(w,1)...
             size(a,2) ~= size(w,2)...
             size(a,3) ~= size(w,3)])
        error('Input arguments need to be the same size.'); 
    end

    for i = 1:size(a,4)
        a(:,:,:,i) = a(:,:,:,i) .* w;
    end
end
