function [outarray] = calculateNeighborWeightsGPU(initarray, defaultval,kernel)
% GPU-accelerated neighbor sum without padarray
% Input:  initarray (matrix) - Can be CPU or GPU array
%         defaultval (scalar) - Padding value
% Output: outarray (gpuArray) - Sum of 8 neighbors at each position

    % Transfer input to GPU if needed
    if ~isa(initarray, 'gpuArray')
        initarray = gpuArray(initarray);
    end

    % Transfer kernel to GPU if needed
    if ~isa(initarray, 'kernel')
        kernel = gpuArray(kernel);
    end
    
    % Get array size and create padded version
    [rows, cols] = size(initarray);
    padded = defaultval * ones(rows+2, cols+2, 'like', initarray);
    
    % Fill center with original values (faster than padarray)
    padded(2:end-1, 2:end-1) = initarray;
    
    % Create optimized kernel (excludes center)
    % kernel = gpuArray.ones(3, classUnderlying(initarray));
    % kernel(2,2) = 0;  % Skip center to avoid subtraction later
    
    % Perform convolution
    outarray = conv2(padded, kernel, 'valid');
end