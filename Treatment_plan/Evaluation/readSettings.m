function [ settings, timeShare, freq ] = readSettings( settingsPath, isSingle )
%readSettings: Reads settings from setting txt-file
%
%   INPUT: Absolut path to settings ending with .txt
%   settingsPath - Absolut path to settings ending with .txt
%   isSingle - Boolean that states if the settings are for single freq
%
%   OUTPUT:
%   settings - settings matrix with columns orderes according to freq with
%              amplitude first and then phase
%   freq - frequency vector in exitation order
%   timeShare - time division vector according to frequency


if(isSingle)
    
    freq = caseread(settingsPath);
    freq(2:end,:)= []; % Removes everything but the first row
    [~,freq]=strread(freq', '%s %f');
    timeShare=1;
    
    settingsMat = caseread(settingsPath);
    settingsMat([1 end],:)= []; % Removes the first and last row
    
    % Creates two columns containing amplitude and phase settings
    [amp, phase] = strread(settingsMat', '%f %f');
    
    settings=[amp phase];
    
else
   
    freqAndTime = caseread(settingsPath);
    freqAndTime(3:end,:)= []; % Removes everything but the first 2 rows
    [~,freqAndTime1,freqAndTime2]=strread(freqAndTime', '%s %f %f');
    
    freq=[freqAndTime1(2) freqAndTime2(2)];
    timeShare=[freqAndTime1(1) freqAndTime2(1)];
    
    settingsMat = caseread(settingsPath);
    settingsMat([1 2 end],:)= []; % Removes the first 2 rows and the last row
    
    % Creates two columns containing amplitude and phase settings
    [amp1, phase1, amp2, phase2] = strread(settingsMat', '%f %f %f %f');
    
    settings=[amp1 phase1 amp2 phase2];
    
end

end

