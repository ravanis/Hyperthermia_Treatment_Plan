function [ E ] = ishequal(a,b,eps)
%ISH_EQUAL(a,b)
%  Tests if a and b are "machine epsilon" from eachother. The code
%  works with both octrees and matrices.
    if ~isequal(size(a),size(b))
        E = false;
        return;
    end
    
    MACHINE_EPS_SQ = 10^-14;

    if ~exist('eps','var')
        eps = MACHINE_EPS_SQ;
    end
    
    try
       c = Yggdrasil.Math.abs_sq(a-b);
    catch
       E = false;
       return;
    end
    E = all(all(all(c < eps)));
end

