function [ ] = plot_amp_histograms( settingPath,oneSetting, figNum)
% This function plots histograms for each setting in optimized solution
% that shows amplitudes for each antenna.
%
% INPUTS
% settingPath  -- Path to txt setting file (timeShare, freq, amp, phase)
% oneSetting   -- Boolean, 1 if solution is one setting, 0 if several.
%
% Optional:
% figNum       -- A postive whole number describing what figure number to use

if nargin < 2
    error('Specify path to setting txt-file and oneSetting-boolean.')
elseif nargin > 3
    error('Too many input arguments.')
end

% Read settings from txt file and create squared amplitude vector
[settings, freq, timeShare]=readSettings(settingPath,oneSetting);
M = length(freq); % Nbr of settings
N = size(settings,1); % Nbr of antennas

ampSq = zeros(M,N);
ampSq(1,:) = settings(:,1).^2;

if oneSetting == 0
    for i = 1:M-1
        ampSq(i+1,:)=settings(:,i+2).^2;
    end
end

%Remove settings that are below 1% of solution
removeIndex = (timeShare<0.01);
ampSq(removeIndex,:) = [];
freq(removeIndex) = [];
timeShare(removeIndex) = [];

if nargin < 3
    figure;
else
    figure(figNum);
end

width = 6;

%Plot histograms for each setting
for i = 1:M
    subplot(M+1,width,[-width+1+width*i, width*i-1]);
    hDataSeries = bar(ampSq(i,:)/sum(ampSq(i,:)),'stacked');
    XTick = 1:size(ampSq,2);
    if i == M
        set(gca,'XTick',XTick)
        set(gca,'XTickLabel',createXLable(XTick))
        set(gca,'xlim',[0.5,size(ampSq,2)+0.5]);
        set(gca,'XTickLabelRotation',45)
    else
        set(gca,'xlim',[0.5,size(ampSq,2)+0.5]);
        set(gca,'XTick',XTick)
        set(gca,'XTickLabel',[])
    end
    
    set(gca,'ylim',[0, max(ampSq(i,:)/sum(ampSq(i,:)))*1.6],'box','off')
    set(gca,'TickLength',[ 0 0 ])
    set(gca,'YTickLabel','')
    labels = createPercLable(ampSq(i,:));
    hText = text(1:size(ampSq,2), ampSq(i,:)/sum(ampSq(i,:)), labels);
    set(hText, 'VerticalAlignment','bottom', 'FontSize',8);
    set(hText, 'FontSize', 12, 'HorizontalAlignment', 'center');
    box on
end

%Display setting info
for i = 1:M
    ax  = subplot(M+1,width,width*i);
    descr = {['Setting nbr: ' num2str(i)];
        ['Frequency: ' num2str(freq(i)) ' MHz'];
        ['Time share: ' sprintf('%3.1f%%',100*timeShare(i))]};
    text(.015,0.35,descr);
    set(text,'Interpreter', 'latex','FontSize', 10);
    set ( ax, 'visible', 'off')
end

c = gcf;
c.Position(3) = 90*size(ampSq,2) + 200;
old_height = c.Position(4);
c.Position(4) = 90*M+180;
c.Position(2) = c.Position(2) + old_height - c.Position(4);
end

function [labels] = createXLable(XTick)
%Create labels for antenna nbr
stri = arrayfun(@(s)sprintf('Ant. %d',s),XTick,'UniformOutput',false);
labels = str2mat(stri(XTick));
end

function [labels] = createPercLable(ampSqVec)
%Create labels for amplitude percentage
labels = cell(1,length(ampSqVec));
for i = 1:length(labels)
    labels{i} =  sprintf('%3.1f%%',100*ampSqVec(i)/sum(ampSqVec));
end
end
