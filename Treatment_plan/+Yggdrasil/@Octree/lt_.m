function a = lt_(a, b)
%output = LT_(a, b)
%  Equavivalent to matrix a<b function. This will create a logical octree.
    % If a is not a octree then b must be one
    if ~isa(a, 'Yggdrasil.Octree')
        a = (b-a);
        a.data = a.data > 0;
        return;
    end
    % Othwerwise a is a octree and b might be one
    a = (a-b);
    a.data = a.data < 0;
end
