function [y,E_opt] = HTQ_(X,tumor_oct,healthy_tissue_oct, Efield_objects,mapp_real_to_Cpoly,mapp_imag_to_Cpoly,mapp_fvar_to_realvar,n)
% Function that calculates HTQ and converts the polynomial HTQ solver 
% arguments X to complex amplitudes and applies them to the total Efield.
% ------INPUTS--------------------------------------------------------------
% X:                   Solver argument vector to minimized polynomial M1. 
% weight_denom:        weight in denomenator of M1. Default: matrix with 
%                      true/false for the position of the tumor, in octree format.
% weight_nom:          weight in the nomenator of M1. Default: matrix with true/false 
%                      for the position of healthy tissue, in octree format.
% Efield_objects:      vector of efields in SF-Efield format.
% mapp_real_to_Cpoly:  Conversion vector for real polynomial coefficents.
% mapp_imag_to_Cpoly:  Conversion vector for imag polynomial coefficents.
% mapp_fvar_to_realvar:Conversion vector for polynomial.
% n:                   Length of Efield_objects.
% ------OUTPUTS-------------------------------------------------------------
% y:                   Scalar value of HTQ.
% E_opt:               Optimized Efield. Octree format.
% --------------------------------------------------------------------------

realZ = containers.Map('KeyType','int64','ValueType','double');
imagZ = containers.Map('KeyType','int64','ValueType','double');

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
    
    %CHANGED THE 22TH OF JUNE. THIS WILL RESULT IN A CELL OF OPTIMIZED
    %EFIELDS, NOT THE SUM OF OPTIMIZED EFIELDS
    E_opt = cell(length(Efield_objects),1);
    for i = 1:length(Efield_objects)
        E_opt{i} = coeff(realZ,imagZ,i)*Efield_objects{i};
    end


    E_opt_sum = E_opt{1};
    for i=2:length(Efield_objects)
        E_opt_sum = E_opt_sum + E_opt{i};
    end
    
    y = HTQ(abs_sq(E_opt_sum),tumor_oct,healthy_tissue_oct);
    
   
    
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
