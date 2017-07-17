function oct = reduce(oct, rel_eps)
%oct = REDUCE(oct, rel_eps)
%  Reduces the octree into a octree with given rel_eps

% If eps is not in the input set it to be the octrees as default
    if ~exist('rel_eps', 'var')
        rel_eps = oct.meta.eps;
    end
    mat = oct.to_mat(); % Turns the oct into a mat
    % Then turns it into an octree with specified eps
    oct = Yggdrasil.Octree(mat, 'rel_eps', rel_eps);
    
end
