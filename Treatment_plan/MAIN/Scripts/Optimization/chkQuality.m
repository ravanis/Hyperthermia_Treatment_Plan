function [recommendedTop] = chkQuality(Efield_objects, weight1, weight2)
narginchk(2,3);
    if ~isa(weight1,'Yggdrasil.Octree')
        weight1 = Yggdrasil.Octree(weight1);
    end
    if nargin == 3 && ~isa(weight2,'Yggdrasil.Octree')
        weight2 = Yggdrasil.Octree(weight2);
    end
Q = zeros(length(Efield_objects),1);
    for i = 1:length(Efield_objects)
        e_i = Efield_objects{i};
        P = abs_sq(e_i);
        a = scalar_prod_integral(P,weight1)/1e9;
        if nargin == 2
            b = integral(P)/1e9;
        else
            b = scalar_prod_integral(P,weight2)/1e9;
        end
        Q(i) = a/b;
    end
    A = Q(Q>=max(Q)/10);
    recommendedTop = length(A);
end
    
    