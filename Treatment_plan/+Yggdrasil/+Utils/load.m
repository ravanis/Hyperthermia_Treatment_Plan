function output = load(filename)
%output = LOAD(filename)
%   Simply loads the variable stored in the file, unlike matlabs load
%   that loads all variables as a struct.

file_data = load(filename, '-mat');

field_names = fieldnames(file_data);
if isempty(field_names)
    error('File is empty.')
end
if length(field_names) > 1
    error('File has more than one variable.')
end
output = file_data.(field_names{1});
end

