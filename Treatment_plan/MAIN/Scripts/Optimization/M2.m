function q = M2(P, tumor, healthy_tissue)
% Calculates goal function M2
% -----INPUTS---------------------------------------------
% P:              oct format PLD field 
% tumor:          oct format boolean matrix for tumour
% healthy_tissue: oct format boolean matrix for healthy tissue
% -----OUTPUTS--------------------------------------------
% q:              Scalar value of M2
% --------------------------------------------------------

power2_in_h_t = Yggdrasil.Math.scalar_prod_integral(Yggdrasil.Math.abs_sq(P),healthy_tissue);
power_in_t = Yggdrasil.Math.scalar_prod_integral(P, tumor);
q = power2_in_h_t/power_in_t^2;

end