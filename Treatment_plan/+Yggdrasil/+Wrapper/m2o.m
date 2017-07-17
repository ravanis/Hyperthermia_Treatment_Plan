%[data, adr, N] = M2O( mat, epsilon, enum_order)
% INTERNAL USE
% A wrapper to the mex-file for transforming a matrix into an octree.
% This function is internally used to bridge matlab and C.
% INPUT:
%     mat        - matrix to be transformed
%     rel_eps    - relative approximation error (Passed through)
%     abs_eps    - absolute approximation error (Used by calculations)
%     enum_order - order of enumeration
% OUTPUT:
%     obj        - Octree object TBW

function [obj_data, obj_adr, obj_meta] = m2o( mat, rel_eps, abs_eps, enum_order)

    [is2pow, N] = Yggdrasil.Math.is2pow(size(mat,1));
    obj_meta.N = uint8(N);
    obj_meta.enum_order = uint8(enum_order);
    obj_meta.eps = single(rel_eps);
    [mat_size(1), mat_size(2), mat_size(3)] = Yggdrasil.Utils.size(mat);
    obj_meta.original_matrix_size = uint32(mat_size);

    % Checks if it is a single value octree.
    if all(mat_size == 1)
       obj_adr = uint64([0 1]); % the octree standard for single value octrees
       if all(abs(mat) < abs_eps) % Should it be approximated with 0?
           data_dim = size(mat,4);
           obj_data = complex(single(zeros(data_dim,1))); % Appproximate with 0
       else
           % Squeeze superfluous dimensions
           obj_data = complex(single(squeeze(mat))); 
       end
       return;
    end

    % All matrix sizes need to be the same power of two ~= 0

    % Is it not a 3d matrix?
    if length(size(mat)) > 4
       error('Invalid matrix size, it must contain atleast 3 dimensions.');
    end

    % Are all sizes the same?
    if size(mat,1) ~= size(mat,2) || size(mat,1) ~= size(mat,3)
       error('Invalid matrix size, the first 3 dimensions need to be the same.');
    end

    % The matrix need to be on the format 2^n
    if ~is2pow
       error('Invalid matrix size, the matrix sides should be 2^n.');
    end
    
    data_dim = size(mat,4);
    [obj_data, obj_adr] = Yggdrasil.C.mat_to_oct(...
                                       obj_meta.N,...
                                       uint32(data_dim),...
                                       complex(single(mat)), ...
                                       single(abs_eps), ...
                                       obj_meta.enum_order);
end
