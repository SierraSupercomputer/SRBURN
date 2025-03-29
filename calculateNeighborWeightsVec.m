function [outarray] = calculateNeighborWeightsVec(initarray, defaultval)
%calculateNeighborWeightsVec uses a simple and fast convolution method to
%calculate the sum of each cell's 8 surrounding neighbors, padded by
%defaultval
    
    % Create 3x3 kernel of ones
    kernel = ones(3);
    
    % Pad input with defaultval
    padded = padarray(initarray, [1 1], defaultval);
    
    % Compute sum of neighbors using 2D convolution
    % 'valid' mode trims the padding automatically
    neighbor_sums = conv2(padded, kernel, 'valid');
    
    % Subtract the center value (original array)
    outarray = neighbor_sums - initarray;
end