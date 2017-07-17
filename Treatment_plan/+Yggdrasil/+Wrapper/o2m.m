%[ mat ] = O2M( oct ), an internal octree 2 mat function.
% INTERNAL USE
% An internal function to handle the most basic case of transforming an
% octree into a matrix. The matrix will have a sidelength of 2^N.
% INPUT:
%    oct - any octree
% OUTPUT
%    mat - a 2^oct.N size matrix represented by the octree
function mat = o2m( oct )

    if nargin ~= 1
        error('This function uses one input argument.')
    end
    
    if ~isa(oct,'Yggdrasil.Octree')
        error('The input needs to be an octree.')
    end

    mat = Yggdrasil.C.oct_to_mat(...
                   complex(single(oct.data)),...
                   uint64(oct.adr),...
                   oct.meta.enum_order,...
                   uint32(size(oct.data,1)),...
                   oct.meta.N);
end


