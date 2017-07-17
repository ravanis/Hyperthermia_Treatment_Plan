function [ mat ] = to_mat( oct )
%[ mat ] = TO_MAT( oct )
%  Converts a octree to matrix form
   mat = Yggdrasil.Utils.Octree.oct_to_mat(oct);
end

