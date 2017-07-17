% Returns tissue data and tissue name vector from a specified tissue file

function [data, tissueNames]=importTissueFile(tissueFilePath)

tissueFile = caseread(tissueFilePath);
tissueFile(end-1:end,:)= []; % Removes the last two rows

% Creates two columns containing index and sigma values
[tissueNames, index, eps, mu, sigma, dens] = strread(tissueFile', '%s %d %f %d %f %f',...
    'whitespace', '\t');
data=[index eps mu sigma dens];

end