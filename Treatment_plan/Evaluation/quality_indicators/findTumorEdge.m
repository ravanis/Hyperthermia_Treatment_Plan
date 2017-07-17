% Finds tumor edge in a 2D matrix

function C=findTumorEdge(tissue_slice,tumorIndex)

% Creating binary matrix (tumor tissue = 1)
if size(tumorIndex,2)>1
    tumor1=tissue_slice==tumorIndex(1); 
    tumor2=tissue_slice==tumorIndex(2);
    tumor=tumor1+tumor2;
else
    tumor=(tissue_slice==tumorIndex); 
end

% Use neighbors to see if an element is on the edge
p=zeros(1,2);
ii=1;
for i=2:size(tumor,1)-1
    for j=2:size(tumor,2)-1
            if tumor(i,j)==1 % Do not look at the non-exterior elements

                % Extract the 4 neighbors. Check if any of the neighbors is 0
                neighbor = [tumor(i-1,j), tumor(i+1,j), tumor(i,j-1), tumor(i,j+1)];
                neighborSum=sum(neighbor);

                % If the element has at least one neighboring 0 element - place that point in the point vector
                if neighborSum<=3 
                    p(ii,:)=[i,j];
                    ii=ii+1;
                end
            end
    end
end

% Create binary edge matrix ( edge elements = 0)
C=ones(size(tissue_slice));
if sum(p)>0
    idx=sub2ind(size(C),p(:,1),p(:,2));
    C(idx)=0;
end

end