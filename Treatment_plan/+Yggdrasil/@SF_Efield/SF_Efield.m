classdef SF_Efield < Yggdrasil.Octree
    properties
        frequency;
        arrangement;
        C;
        is_content_local = true;
    end
    properties (Access = protected)
        my_hash;
    end
    methods
        function self = SF_Efield(frequency, antenna_id, arrangement)
            if nargin < 2
                error('Too few input arguments.'); 
            end
            if nargin > 3
                error('Too many input arguments.'); 
            end
            
            % Initialise temporary placeholder octree
            self@Yggdrasil.Octree(NaN);
            self.is_content_local = false; % Use remote content
            
            % Set up internal SF_Efield properties
            self.frequency = frequency;
            if nargin == 2
                self.arrangement = 1;
            else
                self.arrangement = arrangement;
            end
            
            % Set up antenna properties 
            self.C = Yggdrasil.YggMap();
            self.C = self.C + {antenna_id, 1};
            
            % Set up hash
            self.my_hash = {['A' num2str(self.arrangement) ... 
                            'F' num2str(self.frequency)]};
        end
        
        self = store_content(self);
        varargout = fetch_content(obj, varargin);
        function output = hash(self)
            output = self.my_hash; 
        end
        
        output = disp(sf_e);
        output = abs_sq(sf_q);
        
    end
    methods (Access = protected)
        [self, data] = set_data(self, data);
        [self, adr ] = set_adr(self, adr);
        [self, meta] = set_meta(self, meta);
        
        data = get_data(self, data);
        adr = get_adr(self, adr);
        meta = get_meta(self, meta);
        
    end
    methods (Static)
        function output = priority()
           output = priority@Yggdrasil.Octree() + 1; 
        end
        output = plus_(a,b);
        output = mtimes_(a,b);
        output = times_(a,b);
        output = scalar_prod_(a,b);
        output = scalar_prod_integral_(a,b);
     end
 end