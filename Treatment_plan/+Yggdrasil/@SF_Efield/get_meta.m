function meta = get_meta(self, meta)
%meta = GET_META(self, meta)
%   Called just before get.meta
    if ~self.is_content_local
       meta = self.fetch_content('meta');
    end
end