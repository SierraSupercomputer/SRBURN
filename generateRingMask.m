function [mask] = generateRingMask(innerRad,outerRad,sizeN,xOffset,yOffset)
    outer = generateCircleMask(outerRad, sizeN, xOffset, yOffset);
    inner = generateCircleMask(innerRad, sizeN, xOffset, yOffset);
    
    mask = bitxor(outer, inner);
end

