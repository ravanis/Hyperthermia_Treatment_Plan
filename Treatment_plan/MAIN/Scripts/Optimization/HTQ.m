function q = HTQ(P, tumor_tissue,healthy_tissue)
% Calculates HTQ for a PLD field in either mat- or oct-form. 
% ------INPUTS----------------------------------------------
% P:              mat or oct PLD field
% tumor_tissue:   mat och oct with 1 in tumour and 0 otherwise
% healthy_tissue: mat och oct with 1 in healthy tissue and 0 otherwise
% ------OUTPUTS---------------------------------------------
%q:               HTQ value of P
% ----------------------------------------------------------

if isa(P, 'Yggdrasil.Octree')
    P = P.to_mat();
end
if isa(tumor_tissue, 'Yggdrasil.Octree')
    tumor_tissue = tumor_tissue.to_mat();
end
if isa(healthy_tissue, 'Yggdrasil.Octree')
    healthy_tissue = healthy_tissue.to_mat();
end

tumor_tissue = logical(tumor_tissue);
healthy_tissue = logical(healthy_tissue);

PLDtumor = P(tumor_tissue);
meanPLDtumor = mean(PLDtumor);

PLDhealthy = P(healthy_tissue);
PLDv1 = mean(PLDhealthy(PLDhealthy > prctile(PLDhealthy,99)));
% [hasValues, ~]=find(PLDhealthy);
% PLDhealthy_vec=reshape(tumor,size(P,1)*size(P,2)*size(P,3),1);
% PLDhealthy_vec=sort(PLDhealthy_vec,'descend');
% PLDhealthy_vec=PLDhealthy_vec(1:length(hasValues));
% PLDv1=mean(PLDhealthy_vec(1:round(length(sortHealthyPLD_vec).*per)));

q=double(PLDv1/meanPLDtumor);

%--old version--
% 
% denom=Yggdrasil.Math.scalar_prod_integral(P,tumor);
% 
% if isa(P, 'Yggdrasil.Octree')
%     P = P.to_mat();
% end
% if isa(tumor, 'Yggdrasil.Octree')
%     tumor = tumor.to_mat();
% end
%
% vol = ceil(head_minus_tumor_vol*per);
% B = P(~tumor & P ~=0);
% while length(B)>=2*vol
%     medB = median(B);
%     B = B(B>medB);
%     if length(B)<vol
%         B = [B; medB*ones(vol-length(B),1)];
%     end
% end
% B = sort(B,'descend');
% nom = sum(B(1:vol));
% 
% q = double(nom/denom);
end