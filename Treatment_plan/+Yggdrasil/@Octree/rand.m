function [oct] = rand(matsize, rel_eps)
%[oct] = RAND(matsize, rel_eps)
%  Creates a octree corresponding to a randomized matrix with size matsize
%  and epsilon value eps.
    if exist('rel_eps', 'var')
        oct = Yggdrasil.Octree(rand(matsize), 'rel_eps', rel_eps);
    else
        oct = Yggdrasil.Octree(rand(matsize));
    end
end
