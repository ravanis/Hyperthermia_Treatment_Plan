function [self, meta] = set_meta(self, meta)
%meta = SET_META(self, meta)
%   Called just before self.meta is set and ensures a local copy
%   before any modification.
    if ~self.is_content_local
        self = self.store_content();
    end
end
