function [data, adr, meta] = load_maestro( mode, varargin )
%[data, adr, meta] = LOAD_MAESTRO( varargin )
%   Handles the memory usage of SF_Efields. Reason being there are a lot of
%   single frequencies E-fields which are only used once in a while. 
%   load_maestro only stores the last used E-fields and because of lowers
%   memory usage.
    if nargin == 0 || ~ischar(mode)
        error(['Invalid input. First input argument need to be'...
            ' "init" or "fetch" or "disp".']);
    end
    
    persistent get_filename_Efield;
    persistent get_filename_Sigma;
    persistent oct_map;
    persistent next_free_pos;
    persistent release_queue;
    persistent eps_Efield;
    persistent eps_Sigma;
    MAX_LOADED_OCT = 20;
    
    if strcmp('fetch', mode) % Fetch mode
        % Input checks
        if nargin ~= 2
            error('The mode "fetch" need a SF_Efield object.')
        end
        if ~isa(varargin{1},'Yggdrasil.SF_Efield')
            error('Invalid input, can only load data from a SF_Efield.');
        end
        % Check if something is wrong with SF_Efield
        if length(varargin{1}.C) ~= 1
            error(['Invalid Yggdrasil.SF_Efield object. The object does not'...
                ' correspond to only 1 antenna.'])
        end
        % Check if load_maestro is initialised
        if ~exist('get_filename_Efield','var')
            error(['Need to give a filepath generating function before'...
                   ' loading data.'])
        end
        
        file_name = get_filename_Efield(varargin{1}.frequency,... % Frequency
                                        varargin{1}.C.keys... % Antenna id
                                        );
        
        if ~oct_map.isKey(file_name) % Octree is not loaded into load_maestro
            % Load the E-field into maestro. 
            % Ensure there exists a _weighted.oct version of the E-field
            if ~exist([file_name '_weighted.oct'], 'file')
                % Create the _weighted.oct file
                sigma_file_name = get_filename_Sigma(varargin{1}.frequency);
                if exist('eps_Efield','var')
                    % If eps_Efield is set, eps_Sigma is also set
                    Yggdrasil.Utils.Efield.create_Efield_oct(file_name, sigma_file_name, eps_Efield, eps_Sigma);
                else
                    Yggdrasil.Utils.Efield.create_Efield_oct(file_name, sigma_file_name);
                end
            end
            
            % Load the _weighted.oct file
            oct = Yggdrasil.Utils.load([file_name '_weighted.oct']);

            % Check if expected the loaded data have the correct
            if oct.meta.eps > eps_Efield + eps_Sigma + 10*Yggdrasil.Octree.DEFAULT_REL_EPS 
                warning(['Current relative approximation error, eps = '...
                    num2str(eps_Efield + eps_Sigma) ', is '...
                    'smaller than previous eps = '...
                    num2str(oct.meta.eps) '. Consider removing .oct'...
                    ' files to recalculate the octrees.']);
            end
            
            % Check if expected the loaded data have the correct
            if oct.meta.eps < eps_Efield + eps_Sigma - 10*Yggdrasil.Octree.DEFAULT_REL_EPS
                warning(['Current relative approximation error, eps = '...
                    num2str(eps_Efield + eps_Sigma) ', is '...
                    'larger than previous eps = '...
                    num2str(oct.meta.eps) '. This means that the data '...
                    'could be compressed futher. Consider removing .oct'...
                    ' files to recalculate the octrees for higher compression.']);
            end
            
            % Ensure there being a free position in the queue
            if ~isempty(release_queue{next_free_pos})
                % Remove the oldest kept E-field
                oct_map.remove(release_queue(next_free_pos));
            end
            
            % Add the octree to the map
            oct_map(file_name) = oct;
            % and to the queue
            release_queue{next_free_pos} = file_name;
            
            % Increment position variable
            next_free_pos = next_free_pos + 1;
            if length(release_queue) < next_free_pos
                % Wrap around
                next_free_pos = 1;
            end
        end
        
        % Return the loaded octree
        oct  = oct_map(file_name);
        data = oct.data;
        adr  = oct.adr;
        meta = oct.meta;
        
    elseif strcmp('init', mode)
        if nargin < 3
            error(['The mode "init" needs atleast three inputs, mode "init"'...
                ', filename_Efield_function, filename_Sigma_function'])
        end
        if nargin > 5
            error(['The mode "init" can only have atmost 2 optional arguments, '...
                   'at a total of 5 input arguments.'])
        end
        if ~isa(varargin{1},'function_handle')
            error('Second input needs to be a function handle.')
        end
        if ~isa(varargin{2},'function_handle')
            error('Third input needs to be a function handle.')
        end
        if nargin(varargin{1})~= 2
            error(['The function to create filepath to SF_Efields need 2'...
                ' input arguments: Frequency and antenna_id.']) 
        end
        if nargin(varargin{2})~= 1
            error(['The function to create filepath to Sigma data need 1'...
                ' input arguments: Frequency.']) 
        end
        
        if nargin > 3
            if ~Yggdrasil.Utils.isrealscalar(varargin{3})
                error('The approximation error need to be a real scalar');
            end
            eps_Efield = varargin{3};
            eps_Sigma  = eps_Efield;
            if nargin == 5
                if ~Yggdrasil.Utils.isrealscalar(varargin{4})
                    error('The approximation for Sigma error need to be a real scalar');
                end
                eps_Efield = varargin{4};
            end
        else
           eps_Efield = Yggdrasil.Octree.DEFAULT_REL_EPS;
           eps_Sigma  = eps_Efield;
        end
        
        get_filename_Efield = varargin{1};
        get_filename_Sigma  = varargin{2};
        
        oct_map = containers.Map;
        next_free_pos = 1;
        release_queue = cell(MAX_LOADED_OCT,1);
    elseif strcmp('disp', mode)
        get_filename_Efield
        get_filename_Sigma
        oct_map
        next_free_pos
        release_queue
        eps_Efield
        eps_Sigma
    elseif strcmp('clear', mode)
        clear get_filename_Efield;
        clear get_filename_Sigma;
        clear oct_map;
        clear next_free_pos;
        clear release_queue;
        clear eps_Efield;
        clear eps_Sigma;
    elseif strcmp('empty', mode)
        % Empty out all loaded data
        oct_map = containers.Map;
        next_free_pos = 1;
        release_queue = cell(MAX_LOADED_OCT,1);
    else
        error(['Invalid input. First input argument need to be'...
            ' "init" or "fetch" or "disp".']);
    end
end

