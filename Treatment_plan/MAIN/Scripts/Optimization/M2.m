function q = M2(P, weight_denom, weight_nom)
% Calculates goal function M2
% -----INPUTS---------------------------------------------
% P:           oct format PLD field 
% weight_denom:weight in denomenator: default oct format boolean 
%              matrix for tumour
% weight_nom:  weight in nomenator: default oct format boolean 
%              matrix for healthy tissue
% -----OUTPUTS--------------------------------------------
% q:              Scalar value of M2
% --------------------------------------------------------

power2_in_h_t = Yggdrasil.Math.scalar_prod_integral(Yggdrasil.Math.abs_sq(P),weight_nom);
power_in_t = Yggdrasil.Math.scalar_prod_integral(P, weight_denom);
q = power2_in_h_t/power_in_t^2;

end