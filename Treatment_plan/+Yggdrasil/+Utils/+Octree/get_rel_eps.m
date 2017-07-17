function rel_eps = get_rel_eps(mat, abs_eps)
%rel_eps = GET_REL_EPS(mat, abs_eps)
%   From a given absolute approximation error (abs_eps) gives the 
%   corresponding dimensionless relative approximation error (rel_eps)

DATA = sqrt(Yggdrasil.Math.abs_sq(mat));

rel_eps = abs_eps/mean(DATA(:) > abs_eps);

end