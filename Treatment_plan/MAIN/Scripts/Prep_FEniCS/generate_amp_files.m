function generate_amp_files(modelType, freq, nbrEfields, PwrLimit)
% Generates amplitude files needed to loop to find goal temperature in
% FEniCS. Produces two .txt files: amplitudes and ampLimit. 

% Find paths
filename = which('generate_amp_files');
[preppath,~,~] = fileparts(filename);
scriptpath = [preppath filesep '..'];
resultpath = [scriptpath filesep '..' filesep 'Results' filesep ...
     'Input_to_FEniCS' filesep modelType filesep];
settingspath = [scriptpath filesep '..' filesep 'Results' filesep ...
    'P_and_unscaled_settings' filesep];

%Create amplitudes file
fileID1=fopen([resultpath 'amplitudes.txt'],'w');

%enter data in amplitudes file
if length(freq)==1
parampath = [settingspath 'settings_' modelType '_' num2str(freq) 'MHz.txt'];
paramMat = fopen(parampath);
for i=1:nbrEfields
    if i ==1
    for j =1:2
    fscanf(paramMat,'%s',1);
    end
    end
    amp{i} = fscanf(paramMat,'%s',1);
    fscanf(paramMat,'%s',1);
    fprintf(fileID1,'%f\r\n',str2num(amp{i}));
end
end

%create ampLimit file and enter data
fileID2=fopen([resultpath 'ampLimit.txt'],'w');
ampLimit = sqrt(2*PwrLimit*150); % 150 W is the max power per antenna
fprintf(fileID2,'%f\r\n',ampLimit);

end