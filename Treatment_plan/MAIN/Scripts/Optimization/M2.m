function q = M_2(P, tumor)

power2_in_h_t = Yggdrasil.Math.integral(Yggdrasil.Math.abs_sq(P));
power_in_t = Yggdrasil.Math.scalar_prod_integral(P, tumor);
q = power2_in_h_t/power_in_t^2;

end