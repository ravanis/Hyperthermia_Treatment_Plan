function [ mpol_P1, mpol_P2, x, map_cpoly_to_mpol, map_mpol_to_cpoly] = to_mpol( in_poly1 , in_poly2)
% Transforms the 2 CPoly into two mpol objects, the polynomial class used by
% Gloptipoly. Also because CPoly and mpol index variables 
% differently, the function also creates two maps between them. 

if nargin == 1
    in_poly2 = CPoly(0);
end

% Switch from P(z) to P(x+iy)
P1 = reduce(in_poly1.to_real());
P2 = reduce(in_poly2.to_real());

if any(imag(P1.coefficients)~=0) || any(imag(P2.coefficients)~=0)
    error('It is only possible to transform a real valued polynomial to mpol.')
end



map_cpoly_to_mpol = containers.Map('KeyType','int64','ValueType','int64');
map_mpol_to_cpoly = containers.Map('KeyType','int64','ValueType','int64');

% Find every variable
mpol_ind = 1;
for i = 1:length(P1.monom)
    monom = P1.monom{i};
    for j = 1:length(monom)
        cpol_ind = monom(j);
        if ~map_cpoly_to_mpol.isKey(cpol_ind)
            map_cpoly_to_mpol(cpol_ind) = mpol_ind;
            map_mpol_to_cpoly(mpol_ind) = cpol_ind;
            mpol_ind = mpol_ind + 1;
        end
    end
end
for i = 1:length(P2.monom)
    monom = P2.monom{i};
    for j = 1:length(monom)
        cpol_ind = monom(j);
        if ~map_cpoly_to_mpol.isKey(cpol_ind)
            map_cpoly_to_mpol(cpol_ind) = mpol_ind;
            map_mpol_to_cpoly(mpol_ind) = cpol_ind;
            mpol_ind = mpol_ind + 1;
        end
    end
end

% Create the mpol polynomial (Gloptipy)
mpol('x',length(map_cpoly_to_mpol))

mpol_P1 = 0;
for i = 1:length(P1.monom)
    monom = P1.monom{i};
    if isempty(monom)
        mpol_P1 = mpol_P1 + P1.coefficients(i);
    else
        tmp = real(P1.coefficients(i));
        for j = 1:length(monom)
            cpol_ind = monom(j);
            tmp = tmp * x(map_cpoly_to_mpol(cpol_ind));
        end
        mpol_P1 = mpol_P1 + tmp;
    end
end

mpol_P2 = 0;
for i = 1:length(P2.monom)
    monom = P2.monom{i};
    if isempty(monom)
        mpol_P2 = mpol_P2 + P2.coefficients(i);
    else
        tmp = real(P2.coefficients(i));
        for j = 1:length(monom)
            cpol_ind = monom(j);
            tmp = tmp * x(map_cpoly_to_mpol(cpol_ind));
        end
        mpol_P2 = mpol_P2 + tmp;
    end
end

end