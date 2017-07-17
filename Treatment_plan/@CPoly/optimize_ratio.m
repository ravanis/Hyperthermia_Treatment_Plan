function [ realZ, imagZ ] = optimize_ratio( numer_CPoly,denom_CPoly )
%OPTIMIZE_RATIO Summary of this function goes here
%   Detailed explanation goes here
[numer_realP, mapp1_real_to_Cpoly, mapp1_imag_to_Cpoly] = to_real(numer_CPoly);
[denom_realP, mapp2_real_to_Cpoly, mapp2_imag_to_Cpoly] = to_real(denom_CPoly);

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
    = CPoly.real_to_fmap( {numer_realP, denom_realP} );


f = @(X)(CPoly.eval_f(X,numer_CPoly,mapp_CPoly_to_real,mapp_CPoly_to_imag,mapp_realvar_to_fvar) ...
    / CPoly.eval_f(X,denom_CPoly,mapp_CPoly_to_real,mapp_CPoly_to_imag,mapp_realvar_to_fvar));

%X = ones(n);
X = fminsearch(f,rand(n,1));

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
   
end