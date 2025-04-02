function [nextState,volume,surfaceArea] = stepState(curState,fixedMask,kernel,configArgs)
%stepState progresses the state of an NxN array one, following decay
%   stepState uses neighboring cell weights to calculate the delta of a
%   cell, then multiplies it by a mask of fixed points, and subtracts it
%   from the current state. 

% INPUTS

% curState is the current NxN array of values

% fixedMask is an NxN array of binary values, where a 1 represents cells
% that hold a fixed value, this is helpful for defining the boundaries of a
% simulation

% defaultVal is the value that will be used to pad the edge of neighbor
% arrays, such that a value on the leftmost edge of an array will have
% the three left values replaced by defaultval when calculating weights,
% this must be higher than the starting value of your cells, or your edges
% will erode. It's recommended to make it the same as the starting value of
% your cells, I don't quite know what would happen if it wasn't

% wearRate is a coefficient that all value deltas are multiplied by, the
% default value should be 1, higher values lead to faster erosion. Unsure
% how much this affects accuracy/performance

% randIgn is a logical value that can be used to speed up computations at
% the cost of replacing all random values with 0.5. If you don't mind your
% computations being deterministic, this could be worth it

% mode is the mode of calculation used for the calculations, there is
% three options, with different uses.

    % "GPU" utilizes your system's GPU to accelerate matrix processing,
    % this may be the faster option, particularly for very large arrays
    % but requires the associated toolkit and hardware.
    % 
    % "VECTOR" utilizes vectorized processing, but still processes the
    % values on CPU, this is usually the fastest, and doesn't require any
    % toolkits to use. 
    % 
    % "NONVECTOR" utilizes the most basic processing, this is the slowest by
    % far, but may be useful for debugging purposes. This also cannot
    % properly utilize kernel passthrough, and defaults to the hollow ones
    % array.

% OUTPUTS

% nextState is the next simulation frame, fairly simple

% viewState is the curState + the mask

% volume is the sum of the values of the INITIAL step, this does
% not exclude the values of points excluded by the fixed mask, which should
% be precalculated and subtracted outside of this function

% surfaceArea is the number of cells with a value over 1 that are
% surrounded by at least one cell with a value less than the default value
% provided, this is done for the initial step.

if configArgs.randIgn == false
    if configArgs.mode == "GPU"
        randTable = gpuArray.rand(size(curState));
    else
        randTable = rand(size(curState));
    end
end

if configArgs.mode == "VECTOR"
    curWeights = calculateNeighborWeightsVec(curState,configArgs.defaultVal,kernel);
elseif configArgs.mode == "GPU"
    curWeights = calculateNeighborWeightsGPU(curState,configArgs.defaultVal,kernel);
else
    curWeights = calculateNeighborWeights(curState,configArgs.defaultVal);
end

maxWeight = configArgs.defaultVal * configArgs.maxVal; 
curPers = ((maxWeight-curWeights)/maxWeight); %Calculates % of 
% surroundings eroded

if configArgs.randIgn == false
    curDeltas = curPers.*curState.*randTable; %Multiplies the percentage
% of surroundings eroded by the value at that array, then a random
% value
else
    curDeltas = curPers.*curState*0.5;
end

curDeltas = curDeltas * configArgs.wearRate; %Multiplies by wearRate

trueDeltas = curDeltas.*(~fixedMask); %CHECK IF DOING THIS BEFORE OR AFTER MAKES PERF DIF

nextState = curState-trueDeltas;


%Volume calculations


volume = sum(curState,"all");


%Surface area calculations


liveCells = round(curState) == configArgs.defaultVal; %Makes a bit mask of cells with a mass of 5
exposedCells = round(curWeights) < maxWeight; %And where there is exposure

surface = and(and(liveCells,exposedCells),not(fixedMask));

surfaceArea = sum(surface,"all");
