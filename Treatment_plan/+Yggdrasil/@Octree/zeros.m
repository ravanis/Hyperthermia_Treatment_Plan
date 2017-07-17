function [ oct ] = zeros( mat_size, eps )
%[ oct ] = ZEROS( mat_size, (OPTIONAL) eps )
%  Creates an octree with a single 0 value with the size mat_size.
%  INPUT:
%     mat_size - Vector of 3 or 4 integer numbers describing the size
%     eps      - Optional argument of the approximation error, this will only be
%           passed through.
%  OUTPUT:
%     oct      - An octree filled with zeroes
    if nargin ~= 1 && nargin ~= 2
        error('Need one or two input arguments')
    end
    
    if length(mat_size) ~= 3 && length(mat_size) ~= 4
       error('Invalid input dimensions.') 
    end

    % Find the smallest 2^N cubic matrix
    % that can hold the matrix mat
    longest_side_length = max(mat_size(1:3));
    [~,N] = Yggdrasil.Math.is2pow(longest_side_length);

    if length(mat_size) == 4
        data = zeros([1, 1, 1, mat_size(4)]);            
    else % if length(mat_size) == 3
        data = 0;
    end

    % Create a too small octree
    oct = Yggdrasil.Octree(data);
    oct.adr = [0 8^uint64(N)];
    meta = oct.meta;
    % Modify internal variables to match the desired octree
    meta.N = N;
    meta.original_matrix_size = uint32(mat_size(1:3));
    if nargin == 2 % If eps is given
        meta.eps = eps; 
    end
    oct.meta = meta;


end

