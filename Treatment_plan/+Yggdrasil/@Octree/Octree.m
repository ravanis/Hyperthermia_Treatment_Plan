%The great octree class
classdef Octree < Yggdrasil.AbstractOctreePriority & ...
                  Yggdrasil.AbstractOctreeData
    properties (Constant)
        % Default relative epsilon, the approximation error
        DEFAULT_REL_EPS = 1E-8;
        % Global settings for mat to octree regarding subdivision
        DEFAULT_ENUM_ORDER = 1:8
        
        % The largest piece possible to mat_to_oct, this limit
        % exists because of high memory usage when using mat_to_oct.
        MAX_N = 6;
        
        % The smallest piece allowed to be created by subdivision. 
        % This limit is set because processing too small pieces is slow.
        MIN_N = 5;
    end

    methods
        % Constructor for octrees
        % Creates an octree from a matrix mat. An optional argument
        % for the rounding error eps can be given, default is
        % eps = DEFAULT_EPS. Can handle obj of numeric type and subclasses
        % to octrees.
        function self = Octree(obj, varargin)
            import Yggdrasil.*
            % Controls on input arguments
            if nargin == 0
                error('Atleast one input argument is required.');
            end
            
            if mod(nargin,2) == 0
                error('Constructor only have support for flag value pair inputs.')
            end
            
            if numel(obj) == 0
                error('The input object can not be empty.');
            end
                       
            num_optional_arg = (nargin-1);
            for i = 1:2:num_optional_arg
                switch varargin{i}
                    case 'rel_eps'
                        rel_eps = varargin{i + 1};
                    case 'abs_eps'
                        abs_eps = varargin{i + 1};
                    case 'enum_order'
                        enum_order = varargin{i + 1};
                    otherwise
                        error(['Unknown flag ' varargin{i + 1} '.'])
                end
            end
            
            % If obj is a octree or a subclass to Octree
            if isa(obj,'Yggdrasil.Octree')
                if nargin ~= 1
                    error('No options avalible for octree input.')
                end
                self.data = obj.data;
                self.meta = obj.meta;
                self.adr  = obj.adr;
                return;
            elseif ~isnumeric(obj)
                error('Input is not Octreeable.')
            end
            
            % obj is matrix
            
            if ~exist('enum_order','var')
                % Set an order of how to divide matrices into pieces
                enum_order = self.DEFAULT_ENUM_ORDER;
            end

            % Ensure rel_eps to be set
            if ~exist('rel_eps','var')
                if exist('abs_eps','var')
                    rel_eps = Yggdrasil.Utils.Octree.get_rel_eps(obj, abs_eps);
                else
                    rel_eps = self.DEFAULT_REL_EPS;
                end
            end
            
            % From rel_eps calc abs_eps if needed
            if ~exist('abs_eps','var')
                abs_eps = Yggdrasil.Utils.Octree.get_abs_eps(obj, rel_eps);
            end
            
            % Get side lengths
            mat_size = Utils.size( obj,4 );
            if length(mat_size) ~= 4
                error(['Invalid matrix dimension, only 4 dimensional'...
                    ' or lower dimensional matrices are accepted.']);
            end

            % First, check if the matrix is a cubic matrix with 2^N
            % sidelengths
            is_cubic = all( mat_size(2:3) ...
                               == mat_size(1) );
            
            [is_pow_2, N] = Math.is2pow( mat_size(1) );
            % If mat is easy to create an octree from
            if is_cubic && is_pow_2 && N <= Octree.MAX_N  
                % Create it from scratch
                [self.data, self.adr, self.meta] = ...
                    Wrapper.m2o(obj, rel_eps, abs_eps, enum_order);
            else
                % An smart method that recursivly calls the constructor
                % with pieces of the matrix mat, and then merges the 
                % octrees together to form the final octree self.
                [self.data, self.adr, self.meta] = ...
                    Utils.Octree.mat_to_oct(obj, rel_eps, abs_eps, enum_order); 
            end
        end
        
        output = uplus(oct);
        output = uminus(oct);
        output = conj(oct);
        
        output = sum(oct, b);
        output = power(oct, b);
        
        output = not(oct);
        output = any(oct);
        output = all(oct);
        output = logical(oct);
        output = real(oct);
        output = imag(oct);
        
        varargout = size(oct, dim);
        output = integral(oct1, oct2);
        output = abs_sq(input);
        
        output = reduce(oct, eps);
        output = to_mat(oct);
           
        disp(oct);
    end
    methods (Static)
        function output = priority()
           output = 0; 
        end
        
        output = plus_(oct, b);
        output = minus_(oct, b);
        output = times_(oct, b);
        output = mtimes_(oct, b);
        output = mrdivide_(oct, b);
        output = rdivide_(oct, b);

        output = ne_(oct_a, oct_b);
        output = eq_(oct_a, oct_b);
        output = and_(oct_a, oct_b);
        output = or_(oct_a, oct_b);
        output = gt_(oct1, oct2);
        output = lt_(oct1, oct2);
        output = ge_(oct1, oct2);
        output = le_(oct1, oct2);

        output = scalar_prod_integral_(oct1, oct2);
        output = scalar_prod_(oct1, oct2);
        output = weight_(oct, w);

        output = zeros(mat_size, eps);
        output = rand(matsize, eps);
    end
    methods (Access = public, Static)
        output = merge(oct1,oct2,oct3,oct4,oct5,oct6,oct7,oct8);
    end
    
end
