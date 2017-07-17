function [ abs_eps ] = get_abs_eps( mat, rel_eps )
%[ abs_eps ] = GET_ABS_EPS( mat, rel_eps )
%   Solves the equation abs_eps = rel_eps*mean(DATA(DATA >= abs_eps))
%   where DATA = sqrt(sum(mat.^2,4))
%   If the equation has many solutions the abs_eps with the largest
%   soloution is returned.
%   This function solves the problem of finding an absolute rounding error
%   abs_eps given a relative rounding error rel_eps. If all values in mat 
%   are not negligible the abs_eps = rel_eps*mean(sqrt(sum(mat.^2,4))). 

if rel_eps == 0
    abs_eps = 0;
    return;
end

% DATA is "size" of all data points  
DATA = single(sqrt(Yggdrasil.Math.abs_sq(mat)));

% This algorithm is built around dividing all points into three groups.
%
% First group "in" are all points that so far are determined to be >=
% abs_eps, aka non-negligible.
%
% Second group "out" are all points that so far are determined to be <
% abs_eps, aka negligible.
%
% Third group "P" are all points that so far are undetermined to be either
% "out" or "in"
%
% The algorithm iteretive move points from P into either "in" or "out".  
% At the same time it moves upper and lower limits of < abs_eps and >= abs_eps.
% When P can not get smaller, upper converges to the soloution.

P = DATA(:); % Start out by P = DATA
clear DATA;
upper = max(P); % A first (too large) approximation of >= abs_eps/rel_eps
lower = mean(P); % A first (too small) approximation of < abs_eps/rel_eps

prev_num_in  = 0; % Last iteration's number of points in "in"
prev_num_not_out = numel(P); % Last iteration's number of points in "out"

has_converged_outside = false; % If "out" is filled

while true
    
    % Start looking at canditates to be moved from "P" to "in"
    put_in = P >= upper*rel_eps;
    if all(~put_in) % If there are no candidates
        break;
    else
        % Move candidates from "P" to "in" and recalculate the upper bound
        num_in = sum(put_in(:)) + prev_num_in;
        upper = (prev_num_in*upper + sum(P(put_in)))...
                 /num_in;
        P = P(~put_in); % Remove points from P
    end
    
    % Try to move points in "P" to "out", this is only done because 
    % it makes "P" smaller.
    if ~has_converged_outside
        put_out =  P < lower*rel_eps;
        if all(~put_out)
            has_converged_outside = true;
        else    
            num_not_out = prev_num_not_out - sum(put_out(:));
            lower = (lower*prev_num_not_out - sum(P(put_out)))... % Sum of all values not outside
                        /num_not_out; % Number of values
            P = P(~put_out);
        end
    end
end

abs_eps = rel_eps*upper;

end

