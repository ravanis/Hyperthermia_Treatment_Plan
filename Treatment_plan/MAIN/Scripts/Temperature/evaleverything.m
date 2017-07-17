function [funcmat] = evaleverything(minx,miny,minz,maxx,maxy,maxz,phix,phiy,phiz,func_values)
%[values] = evaleverything(minx,miny,minz,maxx,maxy,maxz,phix,phiy,phiz,func_values)
%   Converts from linear function space to cubical matrix representation.
%   Inputs:
%   minx,...,maxz: The box at which to evaluate the functions
%   phix,phiy,phiz: Position of all corners of all tethrahedrals. 
%                   Indexed [coord,teth], where coord = 1,2,3 corr. x,y,z
%   func_values:    Function values at all corners of all tethrahedrals.
    
    % Init
    funcmat = zeros(maxx-minx+1,maxy-miny+1,maxz-minz+1);
    bar = waitbar(0, 'Calculating temperature...');
    
    % Loop over all teth
    for teth_i=1:size(phix,1)

        % Find bounding box
        boundminx = ceil(min(phix(teth_i,:)));
        boundminy = ceil(min(phiy(teth_i,:)));
        boundminz = ceil(min(phiz(teth_i,:)));
        
        boundmaxx = floor(max(phix(teth_i,:)));
        boundmaxy = floor(max(phiy(teth_i,:)));
        boundmaxz = floor(max(phiz(teth_i,:)));
        
        boundminx = max(minx,boundminx);
        boundminy = max(miny,boundminy);
        boundminz = max(minz,boundminz);
        
        boundmaxx = min(maxx,boundmaxx);
        boundmaxy = min(maxy,boundmaxy);
        boundmaxz = min(maxz,boundmaxz);
        
        x = boundminx:boundmaxx;
        y = boundminy:boundmaxy;
        z = boundminz:boundmaxz;
        xlen = maxx-minx+1;
        xylen = xlen*(maxy-miny+1);
        
        % Generate all positions of points in the bounding box
        xmesh = kron(x,ones(1,length(y)*length(z)));
        ymesh = repmat(kron(y,ones(1,length(z))), 1, length(x));
        zmesh = repmat(z,1,length(x)*length(y));
        
        % Generate all values, NaN if outisde teth
        values = evalteth(xmesh,ymesh,zmesh,phix(teth_i,:),phiy(teth_i,:),phiz(teth_i,:),func_values(teth_i,:));
        inside_teth = ~isnan(values);
        funcmat(1+(xmesh(inside_teth)-minx)+xlen*(ymesh(inside_teth)-minx)+xylen*(zmesh(inside_teth)-minx)) = values(inside_teth);
        
        if mod(teth_i,10000) == 0
            %disp([num2str(floor(teth_i/size(phix,1)*100)) '%'])
            status = floor(teth_i/size(phix,1)*100)/100;
            waitbar(status)
        end
    end
    close(bar)
end

function [values] = evalteth(x,y,z,phix,phiy,phiz,func_values)
%[values] = EVALTETH(x,y,z,phix,phiy,phiz,func_values)
%   Evaluates a single tethrahedral. All inputs are row-vectors.
    values = zeros(size(x));
    for i = 1:4
        values = values + evalpoint(x,y,z,phix,phiy,phiz,func_values(1));
        % Shift corner
        phix = circulate(phix);
        phiy = circulate(phiy);
        phiz = circulate(phiz);
        func_values = circulate(func_values);
    end
end

function [y] = circulate(x)
%[y] = CIRCULATE(x)
%   Shift vector x forwards
    y = x;
    y(2:end) = x(1:end-1);
    y(1) = x(end);
end

function [values] = evalpoint(x,y,z,phix,phiy,phiz,func_value)
%[values] = EVALPOINT(x,y,z,phix,phiy,phiz,func_value)
%   Evaluates a corner of a tethrahedral
    % Mark center of "mass"
    Gx=sum(phix(:))/4;
    Gy=sum(phiy(:))/4;
    Gz=sum(phiz(:))/4;
    % Get oposing surface normal, pointing outwards
    a = [phix(2)-phix(3),phiy(2)-phiy(3),phiz(2)-phiz(3)]';
    b = [phix(2)-phix(4),phiy(2)-phiy(4),phiz(2)-phiz(4)]';
    normal = cross(a,b);
    normal = normal/norm(normal);
    deltaG = [Gx,Gy,Gz]'-[phix(1),phiy(1),phiz(1)]';
    if normal'*deltaG < 0;
        normal = -normal;
    end
    % Get shortest distance to surface from corner
    dist_to_surface = normal' * ([phix(2);phiy(2);phiz(2)]-[phix(1);phiy(1);phiz(1)]);

    % Find distance from corner
    to_pointx = x-phix(1);
    to_pointy = y-phiy(1);
    to_pointz = z-phiz(1);
    dist_to_point = normal' * [to_pointx; to_pointy; to_pointz];
    alpha = dist_to_point/dist_to_surface;
    
    % Evaluate at each point, NaN if outisde
    values = zeros(size(x)) + NaN;
    inside = 1 >= alpha & alpha >= 0;
    values(inside) = (1-alpha(inside))*func_value;
end