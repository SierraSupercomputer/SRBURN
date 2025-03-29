function [nextState,volume,surfaceArea] = stepState(curState,fixedMask,defaultVal,wearRate,mode)
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

% mode is the mode of calculation used for the calculations, there is
% three options, with different uses.

    % "GPU" utilizes your system's GPU to accelerate matrix processing,
    % this may be the faster option, particularly for very large arrays
    % but requires the associated toolkit and hardware

    % "VECTOR" utilizes vectorized processing, but still processes the
    % values on CPU, this is usually the fastest, and doesn't require any
    % toolkits to use. 

    % "NONVECTOR" utilizes the most basic processing, this is the slowest by
    % far, but may be useful for debugging purposes. 

% OUTPUTS

% nextState is the next simulation frame, fairly simple

% viewState is the curState + the mask

% volume is the sum of the values of the INITIAL step, this does
% not exclude the values of points excluded by the fixed mask, which should
% be precalculated and subtracted outside of this function

% surfaceArea is the number of cells with a value over 1 that are
% surrounded by at least one cell with a value less than the default value
% provided, this is done for the initial step.


if mode == "VECTOR"

    %Wear calculations


    randTable = rand(size(curState)); %This can probably be sped up a lot

    curWeights = calculateNeighborWeightsVec(curState,defaultVal);
    
    maxWeight = defaultVal * 8; 
    curPers = ((maxWeight-curWeights)/maxWeight); %Calculates % of 
    % surroundings eroded

    curDeltasPreRand = curPers.*curState.*randTable; %Multiplies the percentage
    % of surroundings eroded by the value at that array, then a random
    % value

    curDeltas = curDeltasPreRand * wearRate; %Multiplies by wearRate

    trueDeltas = curDeltas.*(~fixedMask); %CHECK IF DOING THIS BEFORE OR AFTER MAKES PERF DIF

    nextState = curState-trueDeltas;


    %Volume calculations


    volume = sum(curState,"all");


    %Surface area calculations


    liveCells = round(curState) == defaultVal; %Makes a bit mask of cells with a mass of 5
    exposedCells = round(curWeights) < maxWeight; %And where there is exposure

    surface = and(and(liveCells,exposedCells),not(fixedMask));

    surfaceArea = sum(surface,"all");
    
elseif mode == "GPU"

    %This code is nearly identical to the vectorized version, except it
    %uses the GPU version of the calculatedNeighborWeights function, and
    %replaces the rand function at the start with a gpuArray generated
    %table

    %Wear calculations


    randTable = gpuArray.rand(size(curState));

    curWeights = calculateNeighborWeightsGPU(curState,defaultVal);
    
    maxWeight = defaultVal * 8; 
    curPers = ((maxWeight-curWeights)/maxWeight); %Calculates % of 
    % surroundings eroded

    curDeltasPreRand = curPers.*curState.*randTable; %Multiplies the percentage
    % of surroundings eroded by the value at that array, then a random
    % value

    curDeltas = curDeltasPreRand * wearRate; %Multiplies by wearRate

    trueDeltas = curDeltas.*(~fixedMask); %CHECK IF DOING THIS BEFORE OR AFTER MAKES PERF DIF

    nextState = curState-trueDeltas;


    %Volume calculations


    volume = sum(curState,"all");


    %Surface area calculations


    liveCells = round(curState) == defaultVal; %Makes a bit mask of cells with a mass of 5
    exposedCells = round(curWeights) < maxWeight; %And where there is exposure

    surface = and(and(liveCells,exposedCells),not(fixedMask));

    surfaceArea = sum(surface,"all");
elseif mode == "NONVECTOR"

    % Identical to the vector section, except for the use of the
    % calculateNeighborWeights function. Probably much slower

    %Wear calculations


    randTable = rand(size(curState)); %This can probably be sped up a lot

    curWeights = calculateNeighborWeights(curState,defaultVal);
    
    maxWeight = defaultVal * 8; 
    curPers = ((maxWeight-curWeights)/maxWeight); %Calculates % of 
    % surroundings eroded

    curDeltasPreRand = curPers.*curState.*randTable; %Multiplies the percentage
    % of surroundings eroded by the value at that array, then a random
    % value

    curDeltas = curDeltasPreRand * wearRate; %Multiplies by wearRate

    trueDeltas = curDeltas.*(~fixedMask); %CHECK IF DOING THIS BEFORE OR AFTER MAKES PERF DIF

    nextState = curState-trueDeltas;


    %Volume calculations


    volume = sum(curState,"all");


    %Surface area calculations


    liveCells = round(curState) == defaultVal; %Makes a bit mask of cells with a mass of 5
    exposedCells = round(curWeights) < maxWeight; %And where there is exposure

    surface = and(and(liveCells,exposedCells),not(fixedMask));

    surfaceArea = sum(surface,"all");
else
    error("Invalid computation mode")
end
