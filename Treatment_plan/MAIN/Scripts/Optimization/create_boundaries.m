function [options, lb, ub]=create_boundaries(particle_settings,n)
% Function that creates boundary conditions for particleswarm.
% ----INPUTS---------------------------------------------
% particle_settings: vector with [swarmsize, max_iterations, stall_iterations]
%                    for particleswarm.
% n:                 number of variables in optimization problem
% ----OUTPUTS-------------------------------------------
% options:           optimoptions for particleswarm
% lb:                lower boundary
% ub:                upper boundary
% -------------------------------------------------------

lb = -ones(particle_settings(1)-1,n);
ub = ones(particle_settings(1)-1,n);
initialVec=zeros(1,n);
initialVec(1:2:end-1)=1;
initialSwarmMat=[initialVec;lb+(lb+ub).*rand(particle_settings(1)-1,n)];

options = optimoptions('particleswarm','SwarmSize',particle_settings(1),...
    'PlotFcn',@pswplotbestf, 'MaxIterations', particle_settings(2), ...
    'MaxStallIterations', particle_settings(3), ...
    'InitialSwarmMatrix', initialSwarmMat);

lb=lb(1,:)';
ub=ub(1,:)';
end