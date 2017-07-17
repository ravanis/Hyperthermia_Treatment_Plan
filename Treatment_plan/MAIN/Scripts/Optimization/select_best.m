function [ E_out ] = select_best(Efield_objects, top, weight1, weight2)

narginchk(3,4);
    
    if ~isa(weight1,'Yggdrasil.Octree')
        weight1 = Yggdrasil.Octree(weight1);
    end

    if nargin == 4 && ~isa(weight2,'Yggdrasil.Octree')
        weight2 = Yggdrasil.Octree(weight2);
    end
    
Q = zeros(length(Efield_objects),1);
    for i = 1:length(Efield_objects)
        e_i = Efield_objects{i};
        P = abs_sq(e_i);
        a = scalar_prod_integral(P,weight1)/1e9;
        if nargin == 3
            b = integral(P)/1e9;
        else
            b = scalar_prod_integral(P,weight2)/1e9;
        end
        Q(i) = a/b;
    end
    
   % Q = Q(Q>=max(Q)/10); % Indexen överensstämmer inte vid borttagningav Q
    [~,I] = sort(Q, 'descend'); 
    
    pick_out= min(top,length(Q));
    E_out = cell(pick_out,1);
    for i = 1:pick_out
        E_out{i} = Efield_objects{I(i)};
    end
end

