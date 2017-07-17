function output = integral(a, w)
%output = INTEGRAL(a, w)
%  Integrates over all elements in an octree with an optional weight

    narginchk(1,2);
    if nargin == 2
        a=a.weight(w);
    end
    
    output = zeros(1, size(a,4));
    for i = 1:length(output)
        output(i) = a.data(i,:)*single(diff(a.adr.'));
    end

end
