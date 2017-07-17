%[data, adr, N] = MAT_TO_OCT(mat, eps, enum_order)
% INTERNAL USE
% This function handles the matrix to octree transformation. This function
% can handle 3d matrices of any size by a divide and conquer recursion
% alogotritm. The actual octree creation is delegated to a dumber function
% only able to convert 2^n sided matrices to octrees.
%
% INPUT:
%    mat        - 3D matrix to be converted
%    eps_rel    - relative accepted error in approximations
%    eps_abs    - absolute accepted error in approximations
%    enum_order - order when building octrees
% OUTPUT: 
%    oct        - An Octree object, but missing the origional_mat_size
%                 variable
function [oct_data, oct_adr, oct_meta] = mat_to_oct(mat, rel_eps, abs_eps, enum_order)

% Get the sizes of the matrix mat
[lvec(1), lvec(2), lvec(3), data_dim] = Yggdrasil.Utils.size(mat);

if any(lvec == 0)
    error('The input have to be a three dimensional matrix.')
end
    
lmax = max(lvec);% The longest side length of the matrix mat
[~,N] = Yggdrasil.Math.is2pow(lmax); % The smallest 2^N matrix to fit
                                     % inside mat
                                     
% How many times the matrix mat can be divided
min_N = Yggdrasil.Octree.MIN_N;
upper_subdiv_limit = max(min_N, N) - min_N; 

% How many times the matrix mat must be divided
max_N = Yggdrasil.Octree.MAX_N;
lower_subdiv_limit = N - min(max_N, N);

% Use the recursion function
[oct] = divide_mat_to_oct([1,1,1], 0); % Divide and eliminate

% Create output
oct_data = oct.data;
oct_adr  = oct.adr;

oct_meta.original_matrix_size = lvec; 
oct_meta.enum_order = enum_order;
oct_meta.N = N;
oct_meta.eps = oct.meta.eps;

    % Handles matToOct of a small part of the matrix. This function is
    % reqursive and will run until subdivs == subdiv_limit or if it's 
    % possible to do use matToOct on unpadded data or if the matrix-piece 
    % is only padding.
    function [oct] = divide_mat_to_oct(pos, subdivs)
        
        % If fully outside the matrix
        if any(pos > lvec)
            % store block as a single zero octree
            n = N - subdivs;
            oct = Yggdrasil.Octree.zeros([2^n 2^n 2^n data_dim], rel_eps);
            return;
        end

        % Forced subdivision to limit memory usage
        if subdivs < lower_subdiv_limit
            oct = subdivide(subdivs, pos);
            return;
        end
        
        block_side = 2^(N-subdivs);
        
        % If fully inside the matrix
        if all(pos-1+block_side <= lvec )
            % Octree the block
            span = 0:block_side - 1;
            oct = Yggdrasil.Octree(...
                  mat(pos(1)+span,pos(2)+span,pos(3)+span,:), ...
                                            'rel_eps', rel_eps,...
                                            'abs_eps', abs_eps);
            return;
        end
        
        % Piece is partially inside matrix. If the subdivision limit hasn't
        % been reached, handle by subdivision 
        if subdivs < upper_subdiv_limit
            oct = subdivide(subdivs, pos);
            return;
        end
        
        % else pad the matrix and octree
        
        % Get the indicies to the piece of the matrix,
        piece_size = lvec - pos + [1,1,1];
        
        % Find the piece of the matrix that inside the block.
        piece_size = min([piece_size;[block_side block_side block_side]]);
        
        % Cut out piece from the matrix
        startx = pos(1);
        starty = pos(2);
        startz = pos(3);
        
        endx = startx + piece_size(1) - 1;
        endy = starty + piece_size(2) - 1;
        endz = startz + piece_size(3) - 1;
        
        % Pad with zeroes to get a 2^N to get the block
        padded_data = pad_to(mat(startx:endx,starty:endy,startz:endz,:)...
                            ,[block_side block_side block_side]);
        oct = Yggdrasil.Octree(padded_data, 'rel_eps', rel_eps,...
                                            'abs_eps', abs_eps);
    end

    function [oct] = subdivide(subdivs, pos)
        small_len = 2^(N-subdivs-1);% The length of the pieces
        octs = cell(1,8);
        for i = 1:8% Divide into 8 pieces
            new_pos = pos + ...
                Yggdrasil.Utils.Octree.index_to_sub(enum_order(i)) .* small_len;
            octs{i} = ...
                divide_mat_to_oct(new_pos, subdivs+1);
        end
        % Put all the pieces together.
        oct = Yggdrasil.Octree.merge(octs{:});
    end
    
end

% Pads the matrix mat to the size given by dim_wanted. It fills mat 
% with zeros using matlabs padarrays' 'post' option.
function [padded] = pad_to(mat,dim_wanted)
    mat_dim = Yggdrasil.Utils.size(mat,3);
    mat_dim = mat_dim(1:3);
    pad_vec = dim_wanted - mat_dim;
    if any(pad_vec < 0) % This function can not make a matrix smaller
        error('Padding by a negitive value is not allowed.')
    end

    if all(pad_vec == 0)% No padding needed to reach dim_wanted
        padded = mat;
    else % Padding needed to reach dim_wanted
        padded =  padarray(mat,[pad_vec 0],0,'post');
    end
end

%Subdivide