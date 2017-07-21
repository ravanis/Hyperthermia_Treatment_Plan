function [X,E_opt] = OptimizeM2(Efield_objects,weight_denom,weight_nom, ...
    nbrEfields, particle_settings, eval_function, healthy_tissue)
% Function that optimizes over function M2.
% Optimization is done by expressing M2 as a polynomial and finding
% complex amplitudes that give the minimum value using particle swarm.
%
% ------INPUTS--------------------------------------------------------------
% Efield_objects:    vector of efields in SF-Efield format.
% weight_denom:      weight in denomenator of M2. Default: matrix with
%                    true/false for the position of the tumor, in octree format.
% weight_nom:        weight in the nomenator of M2. Default: matrix with true/false
%                    for the position of healthy tissue, in octree format.
% nbrEfields:        the number of Efields that are put in to the optimization.
% particle_settings: vector with [swarmsize, max_iterations, stall_iterations]
%                    for particleswarm.
% eval_function:     String with which function value to show in
%                    particleSwarm. Options: 'M1', 'M2' or 'HTQ'.
% healthy_tissue:    oct with 1 for healthy tissue, 0 otherwise.
% ------OUTPUTS--------------------------------------------------------------
% X:                 solver argument for polynomial M2
% E_opt:             optimized Efield.
% --------------------------------------------------------------------------

if nargin==6
    healthy_tissue=weight_nom;
end

% Cut off antennas with low power contribution in select_best
Efield_objects = select_best(Efield_objects, nbrEfields, weight_denom, healthy_tissue);

% Create the two square matrices for the gen. eigenvalue representation
n = nbrEfields;
A = zeros(n,n,n,n);
B = A;
doneWith = A;

% Calculate all integral values
for i = 1:n % pick first Efield
    for j = 1:n % pick second Efield
        P_1 = scalar_prod(Efield_objects{i},Efield_objects{j});
        denom_P1 = weight(P_1,weight_denom);
        nume_P1 = weight(P_1,weight_nom);
        for l = 1:n % pick thrid Efield
            for k = 1:n % pick fourth Efield
                if doneWith(k,l,i,j)
                    A(i,j,k,l) = A(k,l,i,j);
                    B(i,j,k,l) = B(k,l,i,j);
                elseif doneWith(j,i,l,k)
                    A(i,j,k,l) = conj(A(j,i,l,k));
                    B(i,j,k,l) = conj(B(j,i,l,k));
                elseif doneWith(l,k,j,i)
                    A(i,j,k,l) = conj(A(l,k,j,i));
                    B(i,j,k,l) = conj(B(l,k,j,i));
                else
                    P_2 = scalar_prod(Efield_objects{k},Efield_objects{l});
                    A(i,j,k,l) = integral(denom_P1,P_2)/1e9;
                    B(i,j,k,l) = integral(nume_P1,P_2)/1e9;
                end
                doneWith(i,j,k,l) = 1;
            end
        end
    end
end

P_nom = CPoly(0);
P_den = CPoly(0);
% Create the polynomials
for i = 1:n % pick first Efield
    for j = 1:n % pick second Efield
        for k = 1:n % pick first Efield
            for l = 1:n % pick second Efield
                P_nom = P_nom + CPoly(B(i,j,k,l),[-i;j;-k;l]);
                P_den = P_den + CPoly(A(i,j,k,l),[-i;j;-k;l]);
            end
        end
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


% Express M2 as a function of X
f = @(X)optimize_function(X,weight_denom,healthy_tissue,Efield_objects,mapp_real_to_Cpoly,...
    mapp_imag_to_Cpoly,mapp_fvar_to_realvar,n,eval_function);

% Find minimum value to M2(X) with particleswarm
[options, lb, ub]=create_boundaries(particle_settings,n);
[X,~,~,~] = particleswarm(f,n,lb,ub,options);

% Compute M1 value and Efield with the optimal complex amplitudes
% corresponding to solver argument X
[~,E_opt] = optimize_function(X,weight_denom,healthy_tissue, Efield_objects,...
    mapp_real_to_Cpoly,mapp_imag_to_Cpoly,mapp_fvar_to_realvar,n,eval_function);

end

