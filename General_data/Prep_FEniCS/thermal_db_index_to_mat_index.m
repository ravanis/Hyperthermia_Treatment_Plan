function [index_map] = thermal_db_index_to_mat_index()

% A map for the row index of thermal_db-excel sheet, ordered after duke
% tissue file (lowest to highest tissue index). Tumor is given the value of
% blood since it is not in the excel sheet.
index_map = [2 2 4 7 9 13 14 19 20 21 23 24 25 32 19 78 30 33 2 34 35 38 44 ...
            45 46 47 53 55 60 10 61 63 64 65 66 70 71 73 76 78 9 81 91 ...
            85 87 89 90 94 2 4 101 4 102 ];

end