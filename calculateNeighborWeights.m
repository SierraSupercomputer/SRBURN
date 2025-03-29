function [outarray] = calculateNeighborWeights(initarray,defaultval)
%calculateNeighborWeights takes an NxN array of values, and returns an NxN
%array of the sum of the surrounding cells, padding the edges with the
%defualtval
%   Given an NxN array of values, this function pads all sides with the 
%   defaultval value, then uses circshift to create 8
%   subsequent arrays, with the respective positions of -1,-1 to 1,1, trims
%   the padding, then sums all arrays across the z dimension

    postpad = padarray(initarray,[1,1],defaultval);

    [N, ~] = size(postpad);
    shifted_array = zeros(N, N, 8);
    
    % Generate all combinations of shifts in row and column directions
    shifts = [-1 -1; -1 0; -1 1;
               0 -1;        0 1;
               1 -1;  1 0;  1 1];
    
    for i = 1:8
        % Apply circular shift
        shifted_array(:,:,i) = circshift(postpad, shifts(i,:));
    end

    trimmed_and_shifted = trimdata(shifted_array,size(initarray),Side="both");

    sum_shifted_array = sum(trimmed_and_shifted,3);

    outarray = sum_shifted_array;
end


