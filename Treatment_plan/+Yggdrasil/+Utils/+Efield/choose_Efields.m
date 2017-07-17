function [Efield_objects] = choose_Efields(Efield_objects, weight1, weight2)
narginchk(2,3);

if ~isa(weight1,'Yggdrasil.Octree')
    weight1 = Yggdrasil.Octree(weight1);
end

if nargin ~= 2 && ~isa(weight2,'Yggdrasil.Octree')
    weight2 = Yggdrasil.Octree(weight2);
end

disp('Calculating Q-values (quality indicator).')
% Calculate Efield quality indicator Q
Q = zeros(length(Efield_objects),1);
for i = 1:length(Efield_objects)
    e_i = Efield_objects{i};
    P = abs_sq(e_i);
    a = scalar_prod_integral(P,weight1)/1e9;
    if nargin == 2
        b = integral(P)/1e9;
    else
        b = scalar_prod_integral(P,weight2)/1e9;
    end
    Q(i) = a/b;
end
disp('Removing unnecessary Efields to save time.')
% Remove Efields with low score to reduce computation time
Efield_objects = Efield_objects(Q>max(Q)/3);
disp(['Removed ' num2str(sum(Q<=max(Q)/3)) ' Efields.'])

% % Create the two square matrices for the gen. eigenvalue representation
% A = zeros(length(Efield_objects));
% B = A;
% 
% % Calculate all integral values
% for i = 1:length(Efield_objects) % pick first Efield
%     for j = 1:length(Efield_objects) % pick second Efield
%         if i > j % Symmetry case
%             A(i,j) = conj(A(j,i));
%             B(i,j) = conj(B(j,i));
%             continue
%         end
%         e_i = Efield_objects{i};
%         e_j = Efield_objects{j};
%         P = scalar_prod(e_i,e_j);
%         A(i,j) = scalar_prod_integral(P,weight1)/1e9;
%         if nargin == 2
%             B(i,j) = integral(P)/1e9;
%         else
%             B(i,j) = scalar_prod_integral(P,weight2)/1e9;
%         end
%     end
% end
% 
% P_nom = CPoly(0);
% P_den = CPoly(0);
% n = length(Efield_objects);
% 
% % Create the polynomials
% for i = 1:n % pick first Efield
%     for j = 1:n % pick second Efield
%         P_nom = P_nom + CPoly(B(i,j),[-i;j]);
%         P_den = P_den + CPoly(A(i,j),[-i;j]);
%     end
% end
% 
% [reZ,imZ] = CPoly.optimize_ratio(P_nom,P_den);
% 
% largest = 0;
% for i = 1:n
%     largest = max([largest, abs(coeff(reZ,imZ,i))]);
% end
% 
% KEYS = reZ.keys;
% for i = 1:length(KEYS)
%     k = KEYS{i};
%     reZ(k) = reZ(k)/largest;
% end
% KEYS = imZ.keys;
% for i = 1:length(KEYS)
%     k = KEYS{i};
%     imZ(k) = imZ(k)/largest;
% end
% E_opt = cell(size(length(Q)));
% %E_opt(1) = coeff(reZ,imZ,1)*Efield_objects{1};
% for i = 1:length(Efield_objects)
%     E_opt{i} = coeff(reZ,imZ,i)*Efield_objects{i};% E_opt +
% end
% 
% end
% 
% function [Z] = coeff(reZ,imZ,id)
% Z = 0;
% if isKey(reZ,id)
%     Z = Z + reZ(id);
% end
% if isKey(imZ,id)
%     Z = Z + 1i*imZ(id);
% end
% 
end