function [ mapp_CPolyvar_to_fvar, mapp_fvar_to_CPolyvar, n] ...
    = real_to_fmap( cell_of_real_poly )
%REAL_TO_FMAP Summary of this function goes here
%   Detailed explanation goes here

for i = 1:length(cell_of_real_poly)
    P = cell_of_real_poly{i};
    if imag(P.coefficients)~=0
        error('Can only map completely real polynomials to functions.')
    end
end

mapp_CPolyvar_to_fvar = containers.Map('KeyType','int64','ValueType','int64');
mapp_fvar_to_CPolyvar = containers.Map('KeyType','int64','ValueType','int64');

% Find every variable
free_ind = 1;
for i = 1:length(cell_of_real_poly)
    P = cell_of_real_poly{i};
    for i = 1:length(P.monom)
        monom = P.monom{i};
        for j = 1:length(monom)
            cpol_ind = monom(j);
            if ~mapp_CPolyvar_to_fvar.isKey(cpol_ind)
                mapp_CPolyvar_to_fvar(cpol_ind) = free_ind;
                mapp_fvar_to_CPolyvar(free_ind) = cpol_ind;
                free_ind = free_ind + 1;
            end
        end
    end
end

n = free_ind-1;

end

