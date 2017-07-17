function [] = ComparePLDv2(PLD1,PLD2,limit,n,n_tilde)


%Let PLD1 and PL2 be Power Loss Density Matrices. Let n be the nth
%percentile, and let n_tilde be the n_tilde percentile, this script creates
%histograms and myslicer plots of the PLD distribution of the positive
%values.
%Limit - The myslicer plots will plot the PLD matrix from 0th percentile to
%the Limit-h percentile.
%
%n and n_tilde creates three distributions: 0-nth percentile, n-n_tilde:th
%percentile and n_tilde-100th percentile. The last histograms y-axis
%follows a logarithmic distribution, since it is more practical. 
%
close all
addpath(genpath(pwd));

freq = 800;

filename=which('CalculatePLD');
[scriptpath,~,~] = fileparts(filename);
tissuePath=[scriptpath,'\Data\df_duke_neck_cst_', num2str(freq),'MHz.txt'];
load([scriptpath, '\Data\tissue_mat.mat']);

[HTQ1, ~, ~]=getHTQ(tissue_Matrix, PLD1,tissuePath);
[HTQ2, ~, ~]=getHTQ(tissue_Matrix, PLD2,tissuePath);

data_1 = prctile(PLD1(:),linspace(1,100));
data_2 = prctile(PLD2(:),linspace(1,100));

PLD1_data = PLD1(:);
PLD2_data = PLD2(:);

% Display quality indicators
disp(['PLD1 ', num2str(freq), 'MHz']);
disp(strcat('Percentage of Positive Values: ',num2str(numel(PLD1_data(PLD1_data > 0))/numel(PLD1))));
disp(strcat('Mean: ',num2str(mean(PLD1(:)))));
disp(strcat('Standard Deviation: ',num2str(std(PLD1(:)))));
disp(strcat('Maximum value: ',num2str(max(PLD1(:)))));
disp(strcat('99 percentile: ',num2str(data_1(99))));
disp(strcat('100 percentile: ',num2str(data_1(100))));
disp(strcat('Skewness: ',num2str(skewness(PLD1(:)))));
disp(strcat('Kurtosis: ',num2str(kurtosis(PLD1(:)))));
 disp(strcat('HTQ: ',num2str(HTQ1)));
disp('------------------------------');
disp(['PLD2 ', num2str(freq), 'MHz']);
disp(strcat('Percentage of Positive Values: ',num2str(numel(PLD2_data(PLD2_data > 0))/numel(PLD2))));
disp(strcat('Mean: ',num2str(mean(PLD2(:)))));
disp(strcat('Standard Deviation: ',num2str(std(PLD2(:)))));
disp(strcat('Maximum value: ',num2str(max(PLD2(:)))));
disp(strcat('99 percentile: ',num2str(data_2(99))));
disp(strcat('100 percentile: ',num2str(data_2(100))));
disp(strcat('Skewness: ',num2str(skewness(PLD2(:)))));
disp(strcat('Kurtosis: ',num2str(kurtosis(PLD2(:)))));
disp(strcat('HTQ: ',num2str(HTQ2)));
disp('------------------------------');
disp(strcat('Difference of maximal element: ',num2str(abs(max(PLD1(:))-max(PLD2(:))))));
disp(strcat('Relative error of HTQ: ',num2str(abs(HTQ1-HTQ2)/HTQ1)));
PLD_per = PLD1 <= data_1(limit); 
PLD1_ms = PLD1.*PLD_per;

figure
myslicer(PLD1_ms); %This creates a myslicer model for all values below the nth percentile
title(strcat(strcat('<', num2str(limit)), ' percentile - PLD1'))

PLD_per = PLD2 <= data_2(limit); 
PLD2_ms = PLD2.*PLD_per;
figure
myslicer(PLD2_ms); %This creates a myslicer model for all values below the nth percentile
title(strcat(strcat('<', num2str(limit)), ' percentile - PLD2'))

% figure
% 
 PLD1 = PLD1(PLD1 ~= 0);
 PLD2 = PLD2(PLD2 ~= 0);
 PLD1_below = PLD1( PLD1 < data_1(n));
 PLD2_below = PLD2( PLD2 < data_2(n));
 PLD1_above = PLD1( PLD1 > data_1(n_tilde));
 PLD2_above = PLD2( PLD2 > data_2(n_tilde));
 PLD1_middle = PLD1(PLD1 > data_1(n));
 PLD1_middle = PLD1_middle(PLD1_middle < data_1(n_tilde));
 PLD2_middle = PLD2(PLD2 > data_2(n));
 PLD2_middle = PLD2_middle(PLD2_middle < data_2(n_tilde));
 
 

nBins = 100;
figure
subplot(2,3,1)

% Set extrema
minY = 0; %there are no values lower than this
maxY = max(max(PLD1_below(:)),max(PLD2_below(:))); %there are no values higher than this

% Add in extrema placeholders to adjust bins to a common scale
yA2 = [PLD1_below(:)' minY maxY];
yB2 = [PLD2_below(:)' minY maxY];

 
% 3 - Scale-adjusted histogram
% This generates histograms you can compare easily

% Bin data
[countsA2, binsA2] = hist(yA2, nBins);
[countsB2, binsB2] = hist(yB2, nBins); 
 
% Remove extrema placeholders from counts
histEndsA = zeros(size(binsA2));
histEndsA(1) = 1; %removes minimum placeholder
histEndsA(end) = 1; %removes maximum placeholder
 
% Repeat for dataset B
histEndsB = zeros(size(binsB2));
histEndsB(1) = 1;
histEndsB(end) = 1;
 
countsA3 = countsA2 - histEndsA;
countsB3 = countsB2 - histEndsB;
 
% Plot histograms

bar(binsA2, countsA3, 'b')
%bar(binsB2, countsB3, 'w')


% Labels
title(strcat('0-',num2str(n),' percentile distribution - PLD1'))
set(gca, 'XLim', [minY maxY])
xlabel('PLD', 'FontSize', 8)
ylabel('counts', 'FontSize', 8)
legend(strcat('Mean: ',num2str(mean(PLD1_below(:)))))
set(gca, 'FontSize', 8)


%%
subplot(2,3,2)

% Set extrema
minY = min(min(PLD1_middle(:)),min(PLD2_middle(:))); %there are no values lower than this
maxY = max(max(PLD1_middle(:)),max(PLD2_middle(:))); %there are no values higher than this

% Add in extrema placeholders to adjust bins to a common scale
yA2 = [PLD1_middle(:)' minY maxY];
yB2 = [PLD2_middle(:)' minY maxY];

 
% 3 - Scale-adjusted histogram
% This generates histograms you can compare easily

% Bin data
[countsA2, binsA2] = hist(yA2, nBins);
[countsB2, binsB2] = hist(yB2, nBins); 
 
% Remove extrema placeholders from counts
histEndsA = zeros(size(binsA2));
histEndsA(1) = 1; %removes minimum placeholder
histEndsA(end) = 1; %removes maximum placeholder
 
% Repeat for dataset B
histEndsB = zeros(size(binsB2));
histEndsB(1) = 1;
histEndsB(end) = 1;
 
countsA3 = countsA2 - histEndsA;
countsB3 = countsB2 - histEndsB;
 
% Plot histograms

bar(binsA2, countsA3, 'b')
%bar(binsB2, countsB3, 'w')

 
% Labels
title(strcat(num2str(n),'-',num2str(n_tilde),' percentile distribution - PLD1'))
set(gca, 'XLim', [minY maxY])
xlabel('PLD', 'FontSize', 8)
ylabel('counts', 'FontSize', 8)
legend(strcat('Mean: ',num2str(mean(PLD1_middle(:)))))
set(gca, 'FontSize', 8)
%%
nBins = 100;
subplot(2,3,3)

% Set extrema
minY = min(min(PLD1_above(:)),min(PLD2_above(:))); %there are no values lower than this
maxY = max(max(PLD1_above(:)),max(PLD2_above(:))); %there are no values higher than this

% Add in extrema placeholders to adjust bins to a common scale
yA2 = [PLD1_above(:)' minY maxY];
yB2 = [PLD2_above(:)' minY maxY];

 
% 3 - Scale-adjusted histogram
% This generates histograms you can compare easily

% Bin data
[countsA2, binsA2] = hist(yA2, nBins);
[countsB2, binsB2] = hist(yB2, nBins); 
 
% Remove extrema placeholders from counts
histEndsA = zeros(size(binsA2));
histEndsA(1) = 1; %removes minimum placeholder
histEndsA(end) = 1; %removes maximum placeholder
 
% Repeat for dataset B
histEndsB = zeros(size(binsB2));
histEndsB(1) = 1;
histEndsB(end) = 1;
 
countsA3 = countsA2 - histEndsA;
countsB3 = countsB2 - histEndsB;

% Plot histograms


bar(binsA2, countsA3, 'b')
%bar(binsB2, countsB3, 'w')

 
% Labels
set(gca, 'XLim', [minY maxY])
set(gca, 'YScale', 'log')
title(strcat(num2str(n_tilde),'-','100th percentile distribution - PLD1'))
xlabel('PLD', 'FontSize', 8)
ylabel('counts', 'FontSize', 8)
legend(strcat('Mean: ',num2str(mean(PLD1_above(:))),',','Max value: ', num2str(max(PLD1_above(:)))))
set(gca, 'FontSize', 8)


%%
nBins = 100;
subplot(2,3,4)

% Set extrema
minY = 0; %there are no values lower than this
maxY = max(max(PLD1_below(:)),max(PLD2_below(:))); %there are no values higher than this

% Add in extrema placeholders to adjust bins to a common scale
yA2 = [PLD1_below(:)' minY maxY];
yB2 = [PLD2_below(:)' minY maxY];

 
% 3 - Scale-adjusted histogram
% This generates histograms you can compare easily

% Bin data
[countsA2, binsA2] = hist(yA2, nBins);
[countsB2, binsB2] = hist(yB2, nBins); 
 
% Remove extrema placeholders from counts
histEndsA = zeros(size(binsA2));
histEndsA(1) = 1; %removes minimum placeholder
histEndsA(end) = 1; %removes maximum placeholder
 
% Repeat for dataset B
histEndsB = zeros(size(binsB2));
histEndsB(1) = 1;
histEndsB(end) = 1;
 
countsA3 = countsA2 - histEndsA;
countsB3 = countsB2 - histEndsB;

% Plot histograms


%bar(binsA2, countsA3, 'b')
bar(binsB2, countsB3, 'w')

 
% Labels
set(gca, 'XLim', [minY maxY])
title(strcat('0','-',num2str(n),'th percentile distribution - PLD2'))
xlabel('PLD', 'FontSize', 8)
ylabel('counts', 'FontSize', 8)
legend(strcat('Mean: ',num2str(mean(PLD2_below(:)))))

set(gca, 'FontSize', 8)
%%
nBins = 100;
subplot(2,3,5)

% Set extrema
minY = min(min(PLD1_middle(:)),min(PLD2_middle(:))); %there are no values lower than this
maxY = max(max(PLD1_middle(:)),max(PLD2_middle(:))); %there are no values higher than this

% Add in extrema placeholders to adjust bins to a common scale
yA2 = [PLD1_middle(:)' minY maxY];
yB2 = [PLD2_middle(:)' minY maxY];

 
% 3 - Scale-adjusted histogram
% This generates histograms you can compare easily

% Bin data
[countsA2, binsA2] = hist(yA2, nBins);
[countsB2, binsB2] = hist(yB2, nBins); 
 
% Remove extrema placeholders from counts
histEndsA = zeros(size(binsA2));
histEndsA(1) = 1; %removes minimum placeholder
histEndsA(end) = 1; %removes maximum placeholder
 
% Repeat for dataset B
histEndsB = zeros(size(binsB2));
histEndsB(1) = 1;
histEndsB(end) = 1;
 
countsA3 = countsA2 - histEndsA;
countsB3 = countsB2 - histEndsB;

% Plot histograms


%bar(binsA2, countsA3, 'b')
bar(binsB2, countsB3, 'w')

 
% Labels
set(gca, 'XLim', [minY maxY])
title(strcat(num2str(n),'-',num2str(n_tilde),'th percentile distribution - PLD2'))
xlabel('PLD', 'FontSize', 8)
ylabel('counts', 'FontSize', 8)
legend(strcat('Mean: ',num2str(mean(PLD2_middle(:)))))
set(gca, 'FontSize', 8)
%%
nBins = 100;
subplot(2,3,6)

% Set extrema
minY = min(min(PLD1_above(:)),min(PLD2_above(:))); %there are no values lower than this
maxY = max(max(PLD1_above(:)),max(PLD2_above(:))); %there are no values higher than this

% Add in extrema placeholders to adjust bins to a common scale
yA2 = [PLD1_above(:)' minY maxY];
yB2 = [PLD2_above(:)' minY maxY];

 
% 3 - Scale-adjusted histogram
% This generates histograms you can compare easily

% Bin data
[countsA2, binsA2] = hist(yA2, nBins);
[countsB2, binsB2] = hist(yB2, nBins); 
 
% Remove extrema placeholders from counts
histEndsA = zeros(size(binsA2));
histEndsA(1) = 1; %removes minimum placeholder
histEndsA(end) = 1; %removes maximum placeholder
 
% Repeat for dataset B
histEndsB = zeros(size(binsB2));
histEndsB(1) = 1;
histEndsB(end) = 1;
 
countsA3 = countsA2 - histEndsA;
countsB3 = countsB2 - histEndsB;

% Plot histograms


%bar(binsA2, countsA3, 'b')
bar(binsB2, countsB3, 'w')

 
% Labels
set(gca, 'XLim', [minY maxY])
set(gca, 'YScale', 'log')
title(strcat(num2str(n_tilde),'-100','th percentile distribution - PLD2'))
xlabel('PLD', 'FontSize', 8)
ylabel('counts', 'FontSize', 8)
legend(strcat('Mean: ',num2str(mean(PLD2_above(:))),',','Max value: ', num2str(max(PLD2_above(:)))))

set(gca, 'FontSize', 8)
end