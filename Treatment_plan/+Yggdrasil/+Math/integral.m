function output = integral(a, weight)
%output = INTEGRAL(a, b)
%  Integrates over all elements in an octree with an optional weight
    narginchk(1,2);
    
    % If octree
    if isa(a,'Yggdrasil.Octree')
        if nargin == 1
            output = a.integral();
            return;
        end
        if nargin == 2
            output = a.integral(weight);
            return;
        end
    end
    
    % If matrix
    if isnumeric(a)
        if nargin == 2
            if isa(weight, 'Yggdrasil.Octree')
                weight = weight.to_mat();
            end
            a = Yggdrasil.Math.weight(a, weight);
        end
        output = zeros(1, size(a,4));
        for i = 1:length(output)
            output(i)  = sum(sum(sum(a(:,:,:,i))));
        end
        return;
    end
    
    error(['Do not know how to integrate objects of type' class(a) '.'])
    
end
