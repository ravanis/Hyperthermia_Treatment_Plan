function create_bnd_matrices(overwriteOutput ,tissue_mat, water_ind, bnd_heat_trans, bnd_temp, modelType)
%CREATE_BND_MATRICES(overwriteOutput, tissue_mat, water_ind, bnd_heat_trans, bnd_temp)
%   From boundary condition, generates boundary matrices that describes the
%   boundary condition at each point of the volume.
exist_HT            = exist(get_path('bnd_heat_transfer_mat', modelType),'file');
exist_temp          = exist(get_path('bnd_temp_mat', modelType),'file');
exist_temp_times_HT = exist(get_path('bnd_temp_mat', modelType),'file');

if all([exist_HT, exist_temp, exist_temp_times_HT]) && ~overwriteOutput
    return;
end

% Mark the skin surface boundary with body/air/water
[surface_inner, surface_outer] = fetch_surface(tissue_mat, water_ind);

bnd_heat_trans_mat = bnd_heat_trans(surface_inner);
bnd_temp_mat =  bnd_temp(surface_outer);
bnd_temp_times_ht_mat = bnd_heat_trans_mat .* bnd_temp_mat;

save(get_path('bnd_heat_transfer_mat', modelType), 'bnd_heat_trans_mat', '-v7.3');
save(get_path('bnd_temp_mat', modelType), 'bnd_temp_mat', '-v7.3');
save(get_path('bnd_temp_times_ht_mat', modelType), 'bnd_temp_times_ht_mat', '-v7.3');
end

