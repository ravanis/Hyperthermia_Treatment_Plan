function [y] = C(Q,P,tumor)
%Q, P and tumor are octrees. 

%The function below is proportional to the function C(Q) defined in the
%pdf, optimizing this objective function is equivalent to other objective
%function.


% if isa(P, 'Yggdrasil.Octree')
%     P_mat = P.to_mat();
% end
% 
% if isa(Q, 'Yggdrasil.Octree')
%     Q_mat = Q.to_mat();
% end

nom = Yggdrasil.Math.scalar_prod_integral(Q,P);
denom = Yggdrasil.Math.scalar_prod_integral(Q, tumor);

%Yggdrasil.Math.scalar_prod_integral(P, tumor)*
y = nom/denom;


end

