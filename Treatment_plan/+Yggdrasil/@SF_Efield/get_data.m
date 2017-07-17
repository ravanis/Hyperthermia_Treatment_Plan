function data = get_data(self, data)
%data = GET_DATA(self, data)
%   Called just before get.data
    if ~self.is_content_local
       data = self.fetch_content('data');
    end
end