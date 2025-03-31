% Demo program!
% This program is a bit of a strung together example of how to use the
% SRBURN simulator program. It has a full set of configs at the start, and
% is a good way to learn simple simulations.

sizeN = 500; %Size of the array
defaultVal = 5; %defaultVal, this doesn't actually change anything if wearRate is set to 1
timeout = 1000; %Number of steps the sim will cycle through before timing out
estVals = 1000; %Number of steps you expect the sim to use, for pre-alloc
heartbeat = false; %Enabling this makes the program output each time a step is completed
randIgn = false; %Approximates random numbers as 0.5 to speed up execution
saveVideo = true; %Saves all states, then plays an animation of them here
mode = "VECTOR"; %Calculation mode, see stepState for more

%Generates a circular binary mask and inverts it, this defines the edge of
%the simulation, in this case the radius is half of the size, meaning it is
%perfectly circumscribed
fixedMask = ~generateCircleMask(sizeN/2,sizeN,0,0);

%Generates a start binary mask, this defines the core geometry
coreMask = generateStarMask(50,150,sizeN,16,0,0);

%Calls the simulation
[states,volume,surfaceArea,time,steps] = runBurnSimNxN(sizeN,coreMask,fixedMask,defaultVal,timeout,estVals,heartbeat,randIgn,saveVideo,mode);

%Completed
fprintf("Finished in %.2f seconds and %d steps.\n",time,steps);

%plays the video, if enabled
if saveVideo == true
    fprintf("Playing animation\n")
    for i = 1:size(states,3)
        frame = states(:,:,i) + fixedMask;
        imagesc(frame)
        axis('square')
        title("Frame #",i)
        pause(0.001)
    end
end

%plots the surface area over time
fprintf("Plotting surface area\n")
plot(surfaceArea);


