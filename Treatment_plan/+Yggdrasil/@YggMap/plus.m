function self = plus(self, rhs)
%self = PLUS(self, rhs)
%   Call by YggMapObj + {key, value} or
%           YggMapObj1 + YggMapObj2
%   If two values share the same key, they are added

    % Ensure self being a Yggdrasil.YggMap
    if ~isa(self,'Yggdrasil.YggMap')
        self = rhs + self; % Switch order
        return;
    end

    % If both are YggMap, merge
    if isa(rhs,'Yggdrasil.YggMap')
        self = merge(self,rhs);
        return;
    end

    % Case should be YggMapObj + {key, value}, testing
    if ~iscell(rhs)
        error('Invalid input, input needs to be a 1x2 cell or a YggMap object.')
    end
    if length(rhs) ~= 2
        error('Invalid input, the length of a pair must be two.')
    end
    
    % Everything ok, do add
    key   = rhs{1};
    value = rhs{2};
    self = add_to(self, key, value);
end

function self = add_to(self, key, value)    
    if isempty(self.keys) % First time
        if numel(key) ~= 1
            error('Input cannot be used as key.');
        end
        if numel(value) ~= 1
            error('Input cannot be stored.');
        end
        self.keys   = key;
        self.values = value;
        return;
    end
    
    % Check for key
    key_found = false;
    for index = 1:length(self.keys)
        if isequaln(self.keys(index),key)
            key_found = true;
            break;
        end
    end

    if key_found
        % Add to existing
        self.values(index) = self.values(index) + value;
    else
        % Create new
        try
            self.keys(end+1)   = key;
        catch
            error(['Type mismatch of keys: (' ...
                class(self.keys) ', ' class(key) ').'])
        end
        
        try 
            self.values(end+1) = value;
        catch
            error(['Type mismatch of values: (' ...
                class(self.values) ', ' class(value) ').'])
        end
    end
end

function self = merge(self, merger)
     for i = 1:merger.length()
         self = self + {merger.keys(i), merger.values(i)};
     end
 end