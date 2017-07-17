function bool = leq(a,b)
%bool = LEQ(a,b)
%   The input data a and b are vectors, which are sorted with the lowest value
%   in the first element. A boolean bool is returned with default value 0, where
%   1 is that a is to be sorted before b and 0 that b should be before a.
    bool = 0;
    %Checks for length differances
    if lenght(a)>lenght(b)
      bool = 1;
    elseif lenght(b)>lenght(a)
        bool = 0;
    end
    %Compares every element in order.
    for i = 1:lenght(a)
        if a(i) ~= b(i)
            if a(i)<b(i)
                bool = 1;
                break;
            end
            bool = 0;
            break;
        end
    end end
