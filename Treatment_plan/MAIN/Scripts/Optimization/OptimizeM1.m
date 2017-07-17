function [X, E_opt] = OptimizeM1(Efield_objects,tumor_oct,healthy_tissue_oct, nbrEfields)
% function that optimizes over function M1 using particle swarm
% Efield_objects - vector of efields in SF-Efield format
% tumor_oct - matrix with true/false for the position of the tumor, in
% octree format
% healthy_tissue_oct - matrix with true/false for the position of healthy
% tissue, in octree format
% nbrEfields - the number of Efields that are put in to the optimization
    
    %PUT IN SELECT_BEST HERE
    weight1 = tumor_oct;
    Efield_objects = select_best(Efield_objects, nbrEfields, weight1);
    
    % Create the two square matrices for the gen. eigenvalue representation
    A = zeros(length(Efield_objects));
    B = A;

    % Calculate all integral values
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

            A(i,j) = scalar_prod_integral(P,weight1)/1e9;
            if nargin >= 3
                B(i,j) = integral(P)/1e9;
            else
                B(i,j) = scalar_prod_integral(P,weight2)/1e9;
            end
        end
    end
    
    P_nom = CPoly(0);
    P_den = CPoly(0);
    n = length(Efield_objects);
    % Create the polynomials
    for i = 1:n % pick first Efield
        for j = 1:n % pick second Efield
            P_nom = P_nom + CPoly(B(i,j),[-i;j]);
            P_den = P_den + CPoly(A(i,j),[-i;j]);
        end
    end
    
    [numer_realP, mapp1_real_to_Cpoly, mapp1_imag_to_Cpoly] = to_real(P_nom );
[denom_realP, mapp2_real_to_Cpoly, mapp2_imag_to_Cpoly] = to_real(P_den);

mapp_real_to_Cpoly = containers.Map('KeyType','int64','ValueType','int64');
mapp_imag_to_Cpoly = containers.Map('KeyType','int64','ValueType','int64');
mapp_CPoly_to_real = containers.Map('KeyType','int64','ValueType','int64');
mapp_CPoly_to_imag = containers.Map('KeyType','int64','ValueType','int64');

KEYS = keys(mapp1_real_to_Cpoly);
for i = 1:length(KEYS)
    k = KEYS{i};
    mapp_real_to_Cpoly(k) = mapp1_real_to_Cpoly(k);
end
KEYS = keys(mapp2_real_to_Cpoly);
for i = 1:length(KEYS)
    k = KEYS{i};
    mapp_real_to_Cpoly(k) = mapp2_real_to_Cpoly(k);
end

KEYS = keys(mapp1_imag_to_Cpoly);
for i = 1:length(KEYS)
    k = KEYS{i};
    mapp_imag_to_Cpoly(k) = mapp1_imag_to_Cpoly(k);
end
KEYS = keys(mapp2_imag_to_Cpoly);
for i = 1:length(KEYS)
    k = KEYS{i};
    mapp_imag_to_Cpoly(k) = mapp2_imag_to_Cpoly(k);
end

KEYS = keys(mapp_real_to_Cpoly);
for i = 1:length(KEYS)
    key = KEYS{i};
    mapp_CPoly_to_real(mapp_real_to_Cpoly(key)) = key;
end
KEYS = keys(mapp_imag_to_Cpoly);
for i = 1:length(KEYS)
    key = KEYS{i};
    mapp_CPoly_to_imag(mapp_imag_to_Cpoly(key)) = key;
end

[mapp_realvar_to_fvar, mapp_fvar_to_realvar, n] ...
    = CPoly.real_to_fmap({numer_realP, denom_realP});

f = @(X)M_1(X,tumor_oct,healthy_tissue_oct,Efield_objects,mapp_real_to_Cpoly,mapp_imag_to_Cpoly,mapp_fvar_to_realvar,n);


% lb = -1*ones(n,1);
% ub = ones(n,1);
% 
% [X,fval] = particleswarm(f,n,lb,ub)
%  options = optimset('Plotfcn',@gaplotbestf,'MaxTime',60);
% X = fminsearch(f,ones(n,1),options);




lb = -ones(n,1);
ub = ones(n,1);
options = optimoptions('particleswarm','SwarmSize',20,'PlotFcn',@pswplotbestf, 'MaxIterations', 20, 'MaxStallIterations', 5, 'CreationFcn', @initialSwarm);
[X,fval,exitflag,output] = particleswarm(f,n,lb,ub,options);

% X = ga(f,n,options)
[fval,E_opt] = M_1(X,tumor_oct,healthy_tissue_oct, Efield_objects,mapp_real_to_Cpoly,mapp_imag_to_Cpoly,mapp_fvar_to_realvar,n);

disp(strcat('M1-value post-optimization: ', num2str(fval)))

end

