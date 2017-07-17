function [] = PLDStats(PLD1,PLD2, n)
%This code takes the pointwise difference between two PLD matrices
%and computes summary statistics of them. 

PLD = PLD1 - PLD2;

disp('Every percentile of the difference of the P-matrices')
data = prctile(PLD(:),linspace(1,100));
for i=1:100
   disp(strcat(strcat(num2str(i),' : '),num2str(data(i))))
end

disp(strcat('Mean: ',num2str(mean(PLD(:)))))
disp(strcat('Standard Deviation: ',num2str(std(PLD(:)))))
PLD_per = PLD <= data(n);
PLD = PLD.*PLD_per;

hold on
myslicer(PLD); %This creates a myslicer model for all values below the 98th percentile
title(strcat(strcat('<', num2str(n)), ' percentile'))

figure
myslicer(50*PLD/max(PLD(:)))
title('Normalized')

end
