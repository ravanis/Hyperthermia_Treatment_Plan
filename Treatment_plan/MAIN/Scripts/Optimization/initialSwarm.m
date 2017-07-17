function swarm = initialSwarm(problemStruct)
% custom creation of intial particle positions for particle swarm. Returns
% a matrix with the positions where the one particle is put in the point
% where the settings of the antenna system are nonoptimized and the other
% particles are randomly positioned between lower and upper bound. Each row
% in the matrix represents the position of a particle where the 32 columns
% give every antenna two values that make up each complex number that is the 
% settings of the antennamodel. 
%
% Based on matlabs function pswcreationuniform

nvars = problemStruct.nvars;
options = problemStruct.options;

% Determine finite bounds for the initial particles based on the problem's
% bounds and options.InitialSwarmSpan.
[lb,ub] = determinePositionInitBounds(problemStruct.lb, problemStruct.ub, ...
    options.InitialSwarmSpan);

numParticles = options.SwarmSize;
numInitPositions = size(options.InitialSwarm, 1);
numPositionsToCreate = numParticles - numInitPositions;

% Initialize particles to be created
swarm = zeros(numParticles,nvars);

% Use initial particles provided already
if numInitPositions > 0
    swarm(1:numInitPositions,:) = options.InitialSwarm;
end

% Create remaining particles, randomly sampling within lb and ub
span = ub - lb;
swarm(numInitPositions+1:end,:) = repmat(lb,numPositionsToCreate,1) + ...
    repmat(span,numPositionsToCreate,1) .* rand(numPositionsToCreate,nvars);

% Set position of 1 particle to non-optimized settings of antennas (phase =
% 0, amp = 1)
swarm(numInitPositions+1:end,1) = 0; % imaginary value = 0
for i = 1:2:(nvars) % real number = 1
    if 1>ub
        swarm(1,i) = ub;
    elseif 1<=ub
        swarm(1,i) = 1;
    end
end

% Error if any values are not finite
if ~all(isfinite(swarm(:)))
    error(message('globaloptim:pswcreationuniform:positionNotFinite'));
end
end

function [lb,ub] = determinePositionInitBounds(lb,ub,initialSwarmSpan)
% Update lb and ub using positionInitSpan, so that initial bounds are
% always finite
lbFinite = isfinite(lb);
ubFinite = isfinite(ub);
lbInf = ~lbFinite;
ubInf = ~ubFinite;

% If lb and ub are both finite, do not update the bounds.
% If lb & ub are both infinite, center the range around 0.
idx = lbInf & ubInf;
lb(idx) = -initialSwarmSpan(idx)/2;
ub(idx) = initialSwarmSpan(idx)/2;

% If only lb is finite, start the range at lb.
idx = lbFinite & ubInf;
ub(idx) = lb(idx) + initialSwarmSpan(idx);

% If only ub is finite, end the range at ub.
idx = lbInf & ubFinite;
lb(idx) = ub(idx) - initialSwarmSpan(idx);
end
