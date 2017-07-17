classdef MF_Efield < Yggdrasil.AbstractOctreePriority
    properties
        E = Yggdrasil.YggMap();
        %C; % obs tillagt
    end
    methods
        function self = MF_Efield()%antenna_id)             
            %self.C = Yggdrasil.YggMap();        % Tillagt
            %self.C = self.C + {antenna_id, 1};  % Tillagt
        end
        
        function disp(sf_e)
            % TBW
            disp('Hi, I''m an MF_Efield.');
        end
        
        output = abs_sq(self)
    end
    
    methods (Static, Access = private)
         [x,y,mf_num] = input_chk(a,b)
    end
        
    
    methods (Static)
        
        function output = priority()
           output = Yggdrasil.SF_Efield.priority() + 1; 
        end
        
        a = plus_(a,b)
        a = mtimes_(a,b)
        S = scalar_prod_(a,b)
        S = scalar_prod_integral_(a,b)
        a = weight_(a,w)
        
     end
 end