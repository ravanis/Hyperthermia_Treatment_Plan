function output = eq_(a,b)
%output = EQ_(oct,b)
%  Equivalets to matlabs == function. This will create a logical octree.
%  Returns 0 if the octrees have nonequal data values otherwise returns 1 
    output = ~(a ~= b);
end
