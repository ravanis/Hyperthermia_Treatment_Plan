function [surface_inner, surface_outer] = fetch_surface(tissue_matrix, water_ind)
% [surface_inner, surface_outer] = FETCH_SURFACE(tissue_matrix)
%   Marks boundary material adjacent to skin. 1 for air, 2 for body and 3
%   for water. Two boundary matrices are created, surface_inner and
%   surface_outer. The inner is covered by the outer to enable
%   gradually transition between different adjecent materials.

import Extrapolation.*

% Mark everything as body
surface = ones(size(tissue_matrix));

surface_inner = surface;
surface_outer = surface;

depth = 2;
% Mark the faces as body
surface_inner(1 + depth:end-depth, 1 + depth:end-depth, 1 + depth:end-depth) = 2;

depth = depth + 1;
% Mark the faces as body
surface_outer(1 + depth:end-depth, 1 + depth:end-depth, 1 + depth:end-depth) = 2;

% Mark everything within a five length units from water as three
[dist_sq_to_water, ~] = meijster(tissue_matrix == water_ind);
surface_inner(dist_sq_to_water <= 5^2) = 3;
surface_outer(dist_sq_to_water <= 5^2) = 3;

end