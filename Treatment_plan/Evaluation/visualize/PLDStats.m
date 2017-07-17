function [] = PLDStats(PLD,n)
%Let PLD be the 3 dimensional matrix, and n be an integer between 1 and
%100, which then determines the percentile plot in myslicer. 
close all
%Calculates PLD summary statistics 

disp('Every percentile')
data = prctile(PLD(:),linspace(1,100));
for i=1:100
   disp(strcat(strcat(num2str(i),' : '),num2str(data(i))))
end

disp(strcat('Mean: ',num2str(mean(PLD(:)))))
disp(strcat('Standard Deviation: ',num2str(std(PLD(:)))))
disp(strcat('Maximum value: ',num2str(max(PLD(:)))))
PLD_per = PLD <= data(n); 
PLD = PLD.*PLD_per;

hold on
myslicer(PLD); %This creates a myslicer model for all values below the 98th percentile
title(strcat(strcat('<', num2str(n)), ' percentile'))

figure
myslicer(50*PLD/max(PLD(:)))
title('Normalized')

figure
val = PLD(:);
val = val(val > 0);
med = median(val);

val_1 = val(val > med);
val_2 = val(val < med);

histogram(val_1)
title('Histogram of values over the median with positive PLD')
figure
histogram(val_2)
legend(strcat('mean',num2str(mean(val_1)))), strcat('Std: ',num2str(std(val_1)))
title('Histogram of values below the median with positive PLD')
legend(strcat('mean',num2str(mean(val_2)))), strcat('Std: ',num2str(std(val_2)))
%Wanted changes: make the histogram go on the same figure. Properties
%of the distribution on it. 
end

