List of files:

----------------------------------------------------------------------------
modelType is written: 
	duke_tongue
	duke_tongue_salt
	duke_nasal
	duke_cylinder (normal cylinder but uses duke material parameters)
	child
----------------------------------------------------------------------------

E-FIELDS
Efield_400MHz_A1_modelType.mat
Efield_400MHz_A2_modelType.mat
Efield_400MHz_A3_modelType.mat
Efield_400MHz_A4_modelType.mat
...
Efield_400MHz_An_modelType.mat	% n = number of antennas

TISSUE-MATRIX
tissue_mat_modelType.mat

TISSUE-FILE
df_duke_neck_cst_400MHz.txt % For all duke models
df_chHead_cst_400MHz.txt % For all child models 

BOUNDARY CONDITION
Function that gives values of heat transfer between materials. 
Same for all models.

TEMPERATURE
Gives starting temperatures for body, air and water.

THERMAL COMPILATION - this or thermal_db below
thermal_compilation_duke % För alla duke-modeller
thermal_compilation_child % För alla child-modeller

THERMAL_DB_INDEX_TO_MAT_INDEX - this or thermal_comp
To be used if one wants to update the thermal compilation-file
according to the Excel-database. Excel-file also needed (see Box):
Thermal_dielectric_acoustic_MR_properties_database_V3.0.xlsx

--------------------
All files are expected to be version 7.3 MAT files.
Efields are expected to be A*B*C*3 matrices.
The fourth dimension corresponds to vector components in x,y,z.
