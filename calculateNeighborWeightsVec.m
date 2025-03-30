function [outarray] = calculateNeighborWeightsVec(initarray, defaultval)
% calculateNeighborWeightsVec - Fast 8-neighbor sum without padarray
% Uses manual padding and convolution for speed.
    
    % Pad the array manually by adding a border of defaultval
    [rows, cols] = size(initarray);
    padded = defaultval * ones(rows+2, cols+2, 'like', initarray);  % Preserve input type
    padded(2:end-1, 2:end-1) = initarray;  % Embed original data
    
    % Define 3x3 kernel
    kernel = [1 1 1; 
              1 0 1; 
              1 1 1];
    
    % Convolve and trim padding
    neighbor_sums = conv2(padded, kernel, 'valid');
    
    outarray = neighbor_sums;
end