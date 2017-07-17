function [temp_mat] = read_temperature(filename, minx, miny, minz, maxx, maxy, maxz)
% [temp_mat] = read_temperature(filename, minx, miny, minz, maxx, maxy, maxz)   
%   Reads data from FEniCS and converts it into a matrix based mesh of
%   minx, ..., maxz. Conversion is neccessary because FEniCS uses a
%   function space representation, not a matrix representation.

    % Read the data from the simulation
    temp = hdf5read(filename, 'Temp');
    points = hdf5read(filename, 'P');
    teth = hdf5read(filename, 'T')'+1;
    map = hdf5read(filename, 'Map')+1;
    temp(map) = temp;
    
    
    % Compile data and switch from SI-unit meter to mm
    func_values = temp(teth);
    phix = zeros(size(teth));
    phiy = zeros(size(teth));
    phiz = zeros(size(teth));
    phix(:) = points(1,teth(:))*1000;
    phiy(:) = points(2,teth(:))*1000;
    phiz(:) = points(3,teth(:))*1000;
    
    % Evaluate whole mesh
    temp_mat = evaleverything(minx,miny,minz,maxx,maxy,maxz,phix,phiy,phiz,func_values);
end