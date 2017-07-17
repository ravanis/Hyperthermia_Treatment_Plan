% A better size that does not ignore singleton dimensions.
function [ varargout ] = size(M,min_dims)
    if ~exist('min_dims','var')
        min_dims = 2; % An old MATLAB tradition
    end

    if nargout <= 1
        D = max(min_dims,ndims(M));
        
        varargout{1} = ones(1,D);
        for i = 1:D
            varargout{1}(i) = size(M,i);
        end
        
        return 
    end
    
    varargout = cell(nargout,1);
    for i = 1:nargout
        varargout{i} = size(M,i);
    end
end

