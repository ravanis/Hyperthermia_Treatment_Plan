%mat = OCT_TO_MAT(oct)
% INTERNAL USE
% Creates a matrix from an octree
% This function transforms an octree into a matrix of the origional size.
% INPUT
%    oct - Any octree 
% OUTPUT
%    mat - The matrix representing the octree. It will be of the same
%          size as the origional matrix
function mat = oct_to_mat(oct)
    
    if nargin == 0
       error('Need to input an octree') 
    end
    
    mat = Yggdrasil.Wrapper.o2m(oct);
    d = oct.meta.original_matrix_size;
    mat = mat(1:d(1),1:d(2),1:d(3),:);

end

