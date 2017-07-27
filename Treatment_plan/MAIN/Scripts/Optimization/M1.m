function q = M1(P, weight_denom, weight_nom)
% Function that computes value of goal function M1.
% ----INPUTS------------------------------------------
% P:            PLD distribution in Octree format
% weight_denom: weight in denomenator of M1. Default: matrix with 
%               true/false for the position of the tumor, in octree format.
% weight_nom:   weight in the nomenator of M1. Default: matrix with true/false 
%               for the position of healthy tissue, in octree format.
% ----OUTPUTS----------------------------------------
% q:            Scalar value of M1.
% ---------------------------------------------------

power_in_h_t = Yggdrasil.Math.integral(P, weight_nom)/1e9;
power_in_tumor = Yggdrasil.Math.scalar_prod_integral(P, weight_denom)/1e9;
q = power_in_h_t/power_in_tumor;

end