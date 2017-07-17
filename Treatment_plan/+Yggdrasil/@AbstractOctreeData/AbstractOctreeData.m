%The great abstract octree data class
classdef AbstractOctreeData
    properties
        meta % A metadata struct containing
             %   original_matrix_size: the compressed matrix's size
             %   N: describes the size of the octree
             %   eps: the rounding error
             %   enum_order: the geometrical order used when building the octree
        data % The compacted data, is typically complex single
        adr  % The cumulative volume of the octree
    end

    methods
        % Set data
        function self = set.data(self, data)
            [self, self.data] = self.set_data(data);
        end
        
        % Set adr
        function self = set.adr(self, adr)
            [self, self.adr] = self.set_adr(adr);
        end
        
        % Set metadata meta
        function self = set.meta(self,meta)
            [self, self_meta] = self.set_meta(meta);
            self.meta.N = uint8(self_meta.N);
            self.meta.original_matrix_size = uint32(self_meta.original_matrix_size);
            self.meta.eps = single(self_meta.eps);
            self.meta.enum_order = uint8(self_meta.enum_order);
        end
        
        % Get oct.data
        function data = get.data(self)
            data = self.get_data(self.data);
        end
        
        % Get oct.adr
        function adr = get.adr(self)
            adr = self.get_adr(self.adr);
        end
        
        % Get oct.meta
        function meta = get.meta(self)
            meta = self.get_meta(self.meta);
        end
    end
    methods (Access = protected)
        function [self, data] = set_data(self, data)
        %data = SET_DATA(self, data)
        %   Called just before set.data
        end
        
        function [self, adr] = set_adr(self, adr)
        %adr = SET_ADR(self, adr)
        %   Called just before set.adr
        end
        
        function [self, meta] = set_meta(self, meta)
        %meta = SET_META(self, meta)
        %   Called just before set.meta 
        end
        
        function data = get_data(self, data)
        %data = GET_DATA(self, data)
        %   Called just before get.data
        end
       
        function adr = get_adr(self, adr)
        %adr = GET_ADR(self, adr)
        %   Called just before get.adr
        end
        
        function meta = get_meta(self, meta)
        %meta = GET_META(self, meta)
        %   Called just before get.meta
        end
    end
end
