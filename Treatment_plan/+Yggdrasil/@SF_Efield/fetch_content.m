function varargout = fetch_content(obj, varargin)
%varargout = FETCH_CONTENT(obj, field1, field2 ...)
%   Fetches data, adr and meta through utils.load_maestro.
if nargout == nargin-1
    varargout = cell(nargout,1);
    [data, adr, meta] = Yggdrasil.Utils.Efield.load_maestro('fetch', obj);
    for i = 1:nargout
        if strcmp(varargin{i}, 'data')
            scalar = obj.C.values;
            % Handle common case of unscaled Efield
            if scalar == 1
                varargout{i} = data;
            else
                varargout{i} = scalar * data;
            end
        elseif strcmp(varargin{i}, 'adr')
            varargout{i} = adr;
        elseif strcmp(varargin{i}, 'meta')
            varargout{i} = meta;
        else
            error(['Unknown field: ' varargin{i}]);
        end
    end
elseif nargout < nargin-1
    error('Too few output arguments.');
else
    error('Too many output arguments.');
end

