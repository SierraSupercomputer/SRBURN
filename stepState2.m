function [nextState,viewState,volume,surfaceArea,timeElapsed] = stepState2(curState,fixedMask,defaultVal,wearRate,mode)
% Persistent variable to avoid recomputing constant
persistent maxWeight
if isempty(maxWeight)
    maxWeight = defaultVal * 8; 
end

if mode == "VECTOR"
    tic
    
    % Convert to optimal data types
    curState = single(curState);
    fixedMask = logical(fixedMask);
    
    % Wear calculations
    curWeights = calculateNeighborWeightsVec(curState,defaultVal);
    
    % Combined operations for better speed
    trueDeltas = ((maxWeight-curWeights).*curState.*rand(size(curState), 'single')/maxWeight * wearRate .* (~fixedMask));
    nextState = curState - trueDeltas;
    
    viewState = curState + fixedMask;
    
    % Volume calculation
    volume = sum(curState,"all");
    
    % Optimized surface area calculation
    surface = (round(curState) == 5) & (round(curWeights) < maxWeight) & ~fixedMask;
    surfaceArea = sum(surface,"all");
    
    timeElapsed = toc;
    
elseif mode == "GPU"
    fprintf("Not supported")
elseif mode == "NONVECTOR"
    fprintf("Not supported")
else
    error("Invalid computation mode")
end