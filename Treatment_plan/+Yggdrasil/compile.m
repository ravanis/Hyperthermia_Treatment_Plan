function compile()
%COMPILE()
%   Compiles all of Yggdrasils C files.

% Change directory to Yggdrasil
old_dir = pwd;
[folder, ~, ~] = fileparts(mfilename('fullpath')); % Get compiles folder
cd(folder)

% Do stuff
if ispc 
    % Windows
    cflags = '-std=c99 -O3';
else
    % Non-windows
    cflags = '-std=c99 -O3 -fPIC';
end

% Complie call, x is name of file to be compiled
cc = @(x) eval(['mex CFLAGS=''' cflags ''''...
    ' -DMATLAB -I+C/src/Lib '...
    '-outdir +C '...
    '-output ' x ' +C/src/' x '/' x '.c']);

disp('Compiling Yggdrasil C code.')
cc('mat_to_oct');
cc('oct_to_mat');
cc('plus');
cc('times');
cc('scalar_prod');
cc('weight');
cc('scalar_prod_integral');
disp('Success!')

% Go back to old directory
cd(old_dir)

end