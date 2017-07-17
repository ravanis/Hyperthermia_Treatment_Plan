function [ E_opt ] = focus_Efields_linear( Efield_objects, weight1, weight2 )
%[ E_opt ] = linear_optimization( Efield_objects )
%   Combines the inputed Efields into the best possible combination E_opt 
%   with respect to maximizing
%   the ratio scalar_prod(E,E,weight1)/scalar_prod(E,E,weight2). This is
%   done using generalised eigenvalue formulation.
%   Input:
%      Efield_objects: A cell containing either Yggdrasil.SF_Efield or
%                      Yggdrasil.MF_Efield objects

    narginchk(2,3);

    if ~isa(weight1,'Yggdrasil.Octree')
        weight1 = Yggdrasil.Octree(weight1);
    end

    if nargin ~= 2 && ~isa(weight2,'Yggdrasil.Octree')
        weight2 = Yggdrasil.Octree(weight2);
    end
disp('Calculating Q-values.')
    % Calculate Efield quality indicator Q
    Q = zeros(length(Efield_objects),1);
    for i = 1:length(Efield_objects)
        e_i = Efield_objects{i};
        P = abs_sq(e_i);
        a = scalar_prod_integral(P,weight1);
        if nargin == 2
            b = integral(P);
        else
            b = scalar_prod_integral(P,weight2);
        end
        Q(i) = a/b;
    end
disp('Removing unnecessary Efields to save time.')
    % Remove Efields with low score to reduce computation time
    Efield_objects = Efield_objects(Q>max(Q)/10);
disp(['Removed ' num2str(sum(Q<=max(Q)/10)) ' Efields.'])
    % Create the two square matrices for the gen. eigenvalue representation
    A = zeros(length(Efield_objects));
    B = A;

    %Calculate all integral values
    for i = 1:length(Efield_objects) % pick first Efield
        for j = 1:length(Efield_objects) % pick second Efield
            if i > j % Symmetry case
                A(i,j) = conj(A(j,i));
                B(i,j) = conj(B(j,i));
                continue
            end
            e_i = Efield_objects{i};
            e_j = Efield_objects{j};
            P = scalar_prod(e_i,e_j);

            A(i,j) = scalar_prod_integral(P,weight1);
            if nargin == 2
                B(i,j) = integral(P);
            else
                B(i,j) = scalar_prod_integral(P,weight2);
            end
        end
    end

    % Find the eigenvector corresponding the the largest eigenvalue
    [largest_eigvec, ~] = eigs(A,B,1);

    %Create the E_opt, by applying the largest eigenvalue vec.
    E_opt = largest_eigvec(1)*Efield_objects{1};
    for i = 2:length(Efield_objects)
        E_opt = E_opt + largest_eigvec(i)*Efield_objects{i};
    end

end