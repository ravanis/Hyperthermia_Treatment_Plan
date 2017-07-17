function bin_to_mesh(save_path, bin_mat, rad_bound, dist_bound, tet_vol)

if ~islogical(bin_mat)
    error('Invalid input: second argument needs to be a logical.')
end

% Checks if iso2mesh is installed
if ~exist('v2m.m', 'file')
    error('Can''t find package ''iso2mesh''.') 
end

% Default mesh options
opt.radbound = 7;
opt.distbound = 1;

if ~exist('tet_vol', 'var')
    tet_vol = 50;
end

if exist('rad_bound', 'var')
    opt.radbound = rad_bound; 
end
if exist('dist_bound', 'var')
    opt.distbound = dist_bound; 
end

% Can also be used as options
%opt.keepratio = 1;
%opt.maxnodes = 100;

% Generates the mesh
[no,el,regions,holes] = v2s(bin_mat, 0.5, opt, 'cgalsurf');
[no,el,fa] = s2m(no, el, 1, tet_vol, 'tetgen', regions, holes);
figure
plotmesh(no, fa, el, 'x>0'); %100
axis equal


[~,~,save_format] = fileparts(save_path);

if strcmp(save_format, '.xml')
    % Converting coordinates from millimeter to meter. 
    savexml(no/1000, el, save_path);
elseif strcmp(save_format, '.obj')
    savewav(no/1000, el, save_path);
elseif isempty(save_format)
    error('Missing file ending, need XML or OBJ.')
else
    error('Unknown file format.')
end


end
