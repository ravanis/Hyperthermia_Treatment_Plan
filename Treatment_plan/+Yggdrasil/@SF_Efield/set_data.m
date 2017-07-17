function [self, data] = set_data(self, data)
%data = SET_DATA(self, data)
%   Called just before set.data and ensures a local copy
%   before any modification.
    if ~self.is_content_local
        self = self.store_content();
    end
end
