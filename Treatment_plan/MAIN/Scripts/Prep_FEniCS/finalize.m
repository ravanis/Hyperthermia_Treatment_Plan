function finalize(keyword, nearest_points, modelType, freq)
%FINALIZE(keyword, nearest_points)
%   Last step of data preparation. The mesh used by FEniCS can differ in size
%   w.r.t. the body described in the index matrix. To make sure sampling of mesh
%   points is ok, the data matrices are extrapolated outside the body
%   (nearest neighbor in 3d).

if nargin == 4
    if length(freq)==1
        mat = Extrapolation.load(get_path(keyword, modelType, freq));
        mat = extrapolate_data(mat, nearest_points);
        if length(class(mat))==length('Yggdrasil.Octree')
            mat=to_mat(mat);
        end
    else
        for i = 1:length(freq)
            keywordpath = get_path(keyword, modelType, freq);
            mat = Extrapolation.load(keywordpath{i});
            mat = extrapolate_data(mat, nearest_points);
            if length(class(mat))==length('Yggdrasil.Octree')
                mat=to_mat(mat);
            end
        end
    end
    if length(freq)==1
        save(get_path(['xtrpol_' keyword], modelType, freq), 'mat', '-v7.3');
    elseif length(freq)>1
        for i=1:length(freq)
            path = get_path(['xtrpol_' keyword], modelType, freq);
            save(path{i}, 'mat', '-v7.3');
        end
    end
else
    mat = Extrapolation.load(get_path(keyword));
    mat = extrapolate_data(mat, nearest_points);
    save(get_path(['xtrpol_' keyword], modelType), 'mat', '-v7.3');
end
end

