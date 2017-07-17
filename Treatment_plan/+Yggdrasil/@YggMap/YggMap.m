% YggMap is a class used to store data together with keys. 
% Two important features of this class:
% It uses isequal to check if two keys are the same.
% Values are added with plus, e.g. 'obj + {value,key}'.
%     If obj already contains values with that key, the value will be added
%     to the obj values.
classdef YggMap
    properties
        values;
        keys;
    end
    methods
        function self = YggMap()
        end
        
        self = plus(self, rhs);
        self = mtimes(self, rhs);
        
        function output = length(self)
            output = length(self.keys);
        end
        
        function [iskey, index] = is_key(self,key)
            for index = 1:self.length()
                if isequal(self.keys(index), key)
                    iskey = true;
                    return;
                end
            end
            index = -1;
            iskey = false;
        end
        
        function varargout = subsref(obj,s)
            varargout = cell(1,nargout);
            switch s(1).type
                case '()'
                    [iskey, index] = obj.is_key(s(1).subs{1});
                    if iskey
                        value = obj.values(index);
                    else
                        error('Bad key given, there exist no value with this key.')
                    end
                    
                    if length(s) > 1
                        [varargout{:}] = builtin('subsref',value,s(2:end));
                    else
                        varargout{1} = value;
                    end
                case '.'
                    [varargout{:}] = builtin('subsref',obj,s);
                case '{}'
                    varargout = {builtin('subsref',obj,s)};
                otherwise
                    error('Not a valid indexing expression')
            end
        end
        
        function a = subsasgn(a,s,b)
            switch s(1).type
                case '()'
                    s(1).subs
                    if length(s) == 1
                        [iskey, index] = a.is_key(s(1).subs);
                        
                        if iskey
                            a.values(index) = b;
                        else
                            a = a + {s(1).subs, b};
                        end
                    else
                        a(s(1).subs) = subsasgn(a(s(1).subs),s(2:end),b);
                    end
                case '.'
                    a = builtin('subsasgn',a,s,b);
                case '{}'
                    a = builtin('subsasgn',a,s,b);
                otherwise
                    error('Not a valid indexing expression')
            end
        end
        
    end
end