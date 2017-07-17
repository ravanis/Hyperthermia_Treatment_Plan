function [self, adr] = set_adr(self, adr)
%adr = SET_ADR(self, adr)
%   Called just before set.adr and ensures a local copy
%   before any modification.
    if ~self.is_content_local
        self = self.store_content();
    end
end
