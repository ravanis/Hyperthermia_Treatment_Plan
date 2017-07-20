function [y_val, E_opt] = optimize_function(X,weight_denom,weight_nom,Efield_objects,...
    mapp_real_to_Cpoly,mapp_imag_to_Cpoly,mapp_fvar_to_realvar,n, eval_function, healthy_tissue)
% Function that and converts the polynomial solver arguments X to 
% complex amplitudes and applies them to the total Efield. ParticleSwarm
% optimization function. 
% ------INPUTS--------------------------------------------------------------
% X:                   Solver argument vector to minimized polynomial M1. 
% weight_denom:        weight in denomenator of M1. Default: matrix with 
%                      true/false for the position of the tumor, in octree format.
% weight_nom:          weight in the nomenator of M1. Default: matrix with true/false 
%                      for the position of healthy tissue, in octree format.
% Efield_objects:      Cell vector of efields in SF-Efield format.
% mapp_real_to_Cpoly:  Conversion vector for real polynomial coefficents.
% mapp_imag_to_Cpoly:  Conversion vector for imag polynomial coefficents.
% mapp_fvar_to_realvar:Conversion vector for polynomial.
% n:                   Length of Efield_objects.
% eval_function:       String with which function value to show in
%                      particleSwarm. Options: 'M1', 'M2' or 'HTQ'.
% healthy_tissue:      oct with 1 for healthy tissue, 0 otherwise.
% ------OUTPUTS-------------------------------------------------------------
% y_val:               Scalar value of eval_function.
% E_opt:               Optimized Efield. Octree format.
% --------------------------------------------------------------------------

realZ = containers.Map('KeyType','int64','ValueType','double');
imagZ = containers.Map('KeyType','int64','ValueType','double');

% Apply complex amplitudes X to polynomial
for i = 1:n
    realPol_ind = mapp_fvar_to_realvar(i);
    
    if isKey(mapp_real_to_Cpoly, realPol_ind)
        realZ(mapp_real_to_Cpoly(realPol_ind)) = X(i);
        
    elseif isKey(mapp_imag_to_Cpoly, realPol_ind)
        imagZ(mapp_imag_to_Cpoly(realPol_ind)) = X(i);
    else
        error('Cannot map between solver argument and CPoly variables.')
    end
end   

largest = 0;
    for i = 1:n
        largest = max([largest, abs(coeff(realZ,imagZ,i))]);
    end
    
    KEYS = realZ.keys;
    for i = 1:length(KEYS)
        k = KEYS{i};
        realZ(k) = realZ(k)/largest;
    end
    KEYS = imagZ.keys;
    for i = 1:length(KEYS)
        k = KEYS{i};
        imagZ(k) = imagZ(k)/largest;
    end
    
    % Apply coefficients
    E_opt = cell(length(Efield_objects),1);
    for i = 1:length(Efield_objects)
        E_opt{i} = coeff(realZ,imagZ,i)*Efield_objects{i};
    end

    % Calculate total Efield
    E_opt_sum = E_opt{1};
    for i=2:length(Efield_objects)
        E_opt_sum = E_opt_sum + E_opt{i};
    end
    
    % Calculate value of eval_function
    switch eval_function
        case 'M1'
            y_val = M1(abs_sq(E_opt_sum),weight_denom,weight_nom);
        case 'M2'
            y_val = M2(abs_sq(E_opt_sum),weight_denom,weight_nom);
        case 'HTQ'
            y_val = HTQ(abs_sq(E_opt_sum),weight_denom,healthy_tissue);
    end
end

 function [Z] = coeff(reZ,imZ,id)
    Z = 0;
    if isKey(reZ,id)
        Z = Z + reZ(id);
    end
    if isKey(imZ,id)
        Z = Z + 1i*imZ(id);
    end
end
