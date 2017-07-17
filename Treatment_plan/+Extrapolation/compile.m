function compile()
% COMPILE()
%   Compiles C file for quick nearest neighbour calculations.
%   The algorithm is based around for-loops and can because of this be
%   parallelize with OpenMP. OpenMP is not available in the compiler
%   provided by Mathworks. Compilation is first attempted with OpenMP support 
%   and upon failure fallbacks to non-parrell compilation.

% Change directory to Yggdrasil
old_dir = pwd;
[folder, ~, ~] = fileparts(mfilename('fullpath')); % Get compiles folder
cd(folder)

if ispc % is Windows
    cflags = '-std=c99 -O3';
else
    cflags = '-std=c99 -O3 -fPIC';
end

cc = @(x) eval(['mex CFLAGS=''' cflags ''''...
    ' -DMATLAB '...
    '-output ' x ' ' x '.c']);

cc_par = @(x) eval(['mex CFLAGS=''' cflags ' -fopenmp' ''''...
    ' -lgomp -DMATLAB '...
    '-output ' x ' ' x '.c']);
disp('Compiling Extrapolation C code.')
disp('Attempting to compile with OpenMP-parallelization.')
try
    cc_par('meijster')
catch
    disp('Compilation failed, attempting non-parallelization compilation.')
    cc('meijster')
end
disp('Success!')

cd(old_dir)

end