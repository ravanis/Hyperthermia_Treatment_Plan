function self = store_content(self)
%STORE_CONTENT(self)
%   Permenently retrives and saves data, adr and meta. Will
%   be called before modifications to a SF_Efield object.
    if self.is_content_local == false
        self.is_content_local= true;
        [self.data, self.adr, self.meta] = self.fetch_content(...
                                            'data', 'adr', 'meta');
    else
        error('Can not load data. Data is already loaded.')
    end
end