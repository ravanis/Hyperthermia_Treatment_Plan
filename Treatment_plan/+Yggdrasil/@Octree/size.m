function [ varargout ] = size(oct, dim)
%[ varargout ] = SIZE(oct, dim)
%  Overloads size for octrees. Fully compatible with size of matrix.
    
    if numel(oct) ~= 1
        error('Can not handle arrays of octrees.');
    end

    % Extract the sizes from the octree    
    oct_size = double([oct.meta.original_matrix_size, size(oct.data,1)]);
    
    % Remove trailing singleton dimension, following Matlab standards
    if oct_size(4) == 1
        if oct_size(3) == 1
            oct_size = oct_size(1:2);
        else
            oct_size = oct_size(1:3);
        end
    end
    
    % Specific dimension requested
    if exist('dim','var')
        % Error check of dim
        size(1, dim); % <-- Totally legit!
        
        if nargout > 1
            error('Too many output arguments.');
        end
        
        if dim > length(oct_size) % Singleton
            varargout{1} = 1;
        else
            varargout{1} = oct_size(dim);
        end
        return;
    end
    
    % Typical case, return size without trailing singleton dimensions
    if nargout <= 1
       varargout{1} = oct_size;
       return; 
    end
    
    % Fill out with ones if needed
    oct_size = [oct_size, ones(1,nargout-length(oct_size))];
    
    % Fill all output values, if nargout < ndims, 
    % set last output to product of remaining dimensions
    varargout = num2cell(oct_size(1:nargout-1));
    varargout{nargout} = prod(oct_size(nargout:end));
end
