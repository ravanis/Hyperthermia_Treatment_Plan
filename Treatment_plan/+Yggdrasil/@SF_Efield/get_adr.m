function adr = get_adr(self, adr)
%adr = GET_ADR(self, adr)
%   Called just before get.adr
    if ~self.is_content_local
       adr = self.fetch_content('adr');
    end
end