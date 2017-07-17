function self = mtimes(self, rhs)
    
    % Ensure self being a Yggdrasil.YggMap
    if ~isa(self,'Yggdrasil.YggMap')
        tmp = self;
        self = rhs;
        rhs = tmp;
    end
    
    if ~Yggdrasil.Utils.isscalar(rhs)
        error('Input needs to be a numeric scalar.')
    end
    
    for i = 1:self.length()
        self.values(i) = double(rhs)*self.values(i);
    end
end