function [modified_perf] = modify_perf(rest_perf, ignore, muscle_ind, cerebellum_ind, tumor_ind)
% [modified_perf] = MODIFY_PERF(rest_perf, ignore, muscle_ind, cerebellum_ind, tumor_ind)
% In order to follow the example of the temperature calculations made in
% the Dutch report, TODO add more background of the model. 

perf_muscle = rest_perf(muscle_ind);
perf_cere   = rest_perf(cerebellum_ind);

% Get the linear model parameters modified_perf = rest_perf*a(1) + a(2)
a = [perf_muscle 1; perf_cere 1] \ [5*perf_muscle; 1.1*perf_cere];

% Modify perfusion 
modified_perf                 = a(1)*rest_perf + a(2);
% Do not modify bones, cartillage etc.
modified_perf(ignore)         = rest_perf(ignore);
% Do not modify tissues without any perfusion
modified_perf(rest_perf == 0) = 0;
% Tumor is 
modified_perf(tumor_ind) = modified_perf(muscle_ind)/2;
end