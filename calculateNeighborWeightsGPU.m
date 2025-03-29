function [outarray] = calculateNeighborWeightsGPU(initarray, defaultval)
    % GPU-accelerated neighbor sum using convolution
    % Input:  initarray (matrix) - Can be CPU or GPU array
    %         defaultval (scalar) - Padding value
    % Output: outarray (gpuArray) - Sum of 8 neighbors at each position
    
    % Transfer input to GPU if needed
    if ~isa(initarray, 'gpuArray')
        initarray = gpuArray(initarray);
    end
    
    % Ensure defaultval matches input type
    defaultval = cast(defaultval, 'like', initarray);
    
    % Create 3x3 kernel of ones (correct GPU syntax)
    kernel = gpuArray.ones(3, classUnderlying(initarray));
    
    % Pad array with default value
    padded = padarray(initarray, [1 1], defaultval);
    
    % Perform convolution (automatically GPU-accelerated)
    neighbor_sums = conv2(padded, kernel, 'valid');
    
    % Subtract center values
    outarray = neighbor_sums - initarray;
end