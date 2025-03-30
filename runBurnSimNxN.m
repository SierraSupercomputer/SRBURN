function [states,volume,surfaceArea,time,steps] = runBurnSimNxN(sizeN,coreMask,fixedMask,defaultVal,timeout,estVals,heartbeat,randIgn,saveVideo,mode)
%runBurnSimNxN use the stepState function to run a simulation of cell decay
%   runBurnSimNxN, by default, uses the vectorized CPU version of stepState
%   to run a simulation of cell decay until the total value of all cells,
%   minus fixed cells, rounds to zero. 

% INPUTS
    % sizeN is a positive integer that is used to specify the size of the
    % simulation array, as NxN, typical values range from 250-5000

    % coreMask is a logical array that specifies cells with an inital value
    % set to zero. This is used to define the core geometry of your
    % simulation, but can also be used to create other simulations.
    % Dimensions must be NxN where N = size

    % fixedMask is a logical array that specifies cells whose value doesn't
    % change, and the cell value will always remain defaultVal, use this to
    % outline border geometry
    % Dimensions must be NxN where N = size
    % Values here supercede the values in coreMask when defining the state
    % of a cell

    % defaultVal is the intial value of a cell, which is also the constant
    % value of any cells specified in the fixedMask, recommended value is 5

    % timeout is the number of steps the simulation will run through before
    % stopping automatically. This can be used to prevent runaway
    % simulations in the case of unreachable cells due to fixed geometry or
    % other causes. setting this to zero will disable the timeout, if you
    % do this, be extra sure that your fixedMask does not accidentally
    % speciy any unreachable geomtry, or the simulation will run
    % indefinitely. Recommended value is 1000

    % estVals is the estimated number of states you expect the simulation
    % to cycle through. This is used for pre-allocating array size for
    % performance, but will not actually affect the accuracy of the
    % simulation. Unused values are trimmed. Recommended value is 1000

    % heartbeat is a boolean logical input, where true enables a console
    % log for each step finished, and false makes the program run silently.
    % Enabling this likely slows down the program on smaller array sizes,
    % but has a minimal impact on larger array sizes.

    % saveVideo is a boolean logical input, if set to true, the simulation
    % will create a NxNxM array of all states during the simulation and
    % output it, this can be played back using the imagesc function.
    % Turning this off means you will be unable to visualize your data, but
    % surface area and volume calculations will still work. Turning this
    % off also speeds up the code significantly. If disabled, the function
    % will return an empty array for the states value

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
    % states is an NxNxM array, where N is the size provided earlier, and M
    % is the number of states the simulation cycled through. Each slice in
    % the Z direction represents the full state of the array

    % volume is an N length array, where each value is the sum of all cells
    % in the array at that time, minus the volume of fixed cells
    % (Calculated by multiplying the sum of fixedMask by the defaultVal)

    % surfaceArea is an N length array, where each value represents the
    % number of cells that have a value that rounds to the default value, 
    % and a surrounding weight that rounds to less than 8 * default value.

    % time is the total amount of real time that the simulation took to run

%Initialize the state table
stateTable = ones(sizeN,'single')*defaultVal;

% Set all values specified by the coremask to zero
stateTable = stateTable.*(~coreMask);

% Calculates the volume of fixed cells, to be used later

fixedVol = sum(fixedMask,"all")*defaultVal;

%Create values for loop tracking

if saveVideo
    states = zeros([size(stateTable), estVals], 'like', stateTable); % Same type as input
else
    states = [];
end

outVals = zeros(2, estVals);

volume = fixedVol + 1;
simtime = tic;
track = 1;

while round(volume) > fixedVol && track <= timeout
    % Store current state in preallocated array
    if saveVideo
        states(:,:,track) = stateTable;
    end
    
    % Update simulation
    [stateTable, volume, surface] = stepState(stateTable, fixedMask, defaultVal, 1, randIgn, mode);
    outVals(1,track) = volume;
    outVals(2,track) = surface;
    
    track = track + 1;
    if heartbeat
        fprintf("Step %d complete (Volume: %.2f)\n", track-1, volume);
    end
end

% Trim unused preallocated space
if saveVideo
    states = states(:,:,1:track-1);
end
outVals = outVals(:,1:track-1);

volume = outVals(1,:);
surfaceArea = outVals(2,:);

steps = size(outVals,2);

time = toc(simtime);



