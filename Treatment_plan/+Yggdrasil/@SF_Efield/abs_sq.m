function oct = abs_sq(obj)
%oct = ABS_SQ(obj)
%   Squares a SF_Efield object. This will return an octree describing the 
%   power-density of the E-field.
oct = Yggdrasil.Octree(obj);
oct = abs_sq(oct);

end

