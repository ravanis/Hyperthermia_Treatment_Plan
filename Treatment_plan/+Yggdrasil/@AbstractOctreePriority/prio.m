function output = prio(a, b, a_handle, b_handle)
%output = PRIO(a, b, a_handle, b_handle)
%  This function determines and calls the method from the object
%  with the highest (binary operator) priority. If both a and b
%  have the same priority, then a is favoured.
    if nargin ~= 4
        error('Wrong number of arguments, expected exactly 4 argments.');
    end
    
    if ~ismethod(b, 'priority')
        % b is missing priority, use the method in a
        output = a_handle(a,b);
        return;
    end
    
    if ~ismethod(a, 'priority')
        % a is missing priority, use the method in b
        output = b_handle(a,b);
        return;
    end
    
    if a.priority() >= b.priority()
        output = a_handle(a,b);
    else
        output = b_handle(a,b);
    end
end
