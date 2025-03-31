# SRBURN
A MATLAB based SRB Burn simulator with thrust and weight calculations

simDemonstration is a demo file with all the necessary code and function calls to run an SRB burn simulation. The configs are below:
sizeN = integer, Size of the square array, this can be even or odd, it doesn't really matter. High values drastically increase computation time, I'd recommend starting on a smaller size to ensure your sim is configured as you expect
defaultVal = integer, this doesn't actually change anything in this version of code, as long as it's not zero or negative you're fine
timeout = integer, Number of steps the sim will cycle through before timing out
estVals = integer, Number of steps you expect the sim to use, for pre-allocation of variables
heartbeat = boolean, Enabling this makes the program output each time a step is completed
randIgn = boolean, Approximates random numbers as 0.5 to speed up execution
saveVideo = boolean, Saves all states, then plays an animation of them here
mode = Calculation mode, see below

This program offers three computation modes:

    "GPU" utilizes your system's GPU to accelerate matrix processing,
    this may be the faster option, particularly for very large arrays
    but requires the associated toolkit and hardware

    "VECTOR" utilizes vectorized processing, but still processes the
    values on CPU, this is usually the fastest, and doesn't require any
    toolkits to use. 

    "NONVECTOR" utilizes the most basic processing, this is the slowest by
    far, but may be useful for debugging purposes.

Selecting this as a config will use that computation mode. This mostly changes the convolution method for calculating wear rates based on surrounding cells, but also changes the behavior of random number generation when randIgn is set to false

IMPORTANT NOTE: This program has no checking for GPU capability or memory, it will not gracefully crash and I can make no guarantees of the behavior of the GPU code. I tested it on an RTX 2070 and ran into system RAM issues before I ran into VRAM issues. Your mileage may vary. If you encounter issues, let me know and I can try to fix them.

runBurnSimNxN is the main function of the program, you can build your own framework around it similar to the simDemonstration file, or whatever your intentions are. The arguments to this function define most of the characteristics of the program, and are described below: 

INPUTS

    sizeN is a positive integer that is used to specify the size of the
    simulation array, as NxN, typical values range from 250-5000

    coreMask is a logical array that specifies cells with an inital value
    set to zero. This is used to define the core geometry of your
    simulation, but can also be used to create other simulations.
    Dimensions must be NxN where N = size

    fixedMask is a logical array that specifies cells whose value doesn't
    change, and the cell value will always remain defaultVal, use this to
    outline border geometry
    Dimensions must be NxN where N = size
    Values here supercede the values in coreMask when defining the state
    of a cell, but you may have unintended consquences when calculating 
    the volume and surface area

    defaultVal is the intial value of a cell, which is also the constant
    value of any cells specified in the fixedMask, this value doesn't
    actually matter with the current code, but I haven't gotten around
    to removing it yet.

    timeout is the number of steps the simulation will run through before
    stopping automatically. This can be used to prevent runaway
    simulations in the case of unreachable cells due to fixed geometry or
    other causes. setting this to zero will disable the timeout, if you
    do this, be extra sure that your fixedMask does not accidentally
    speciy any unreachable geomtry, or the simulation will run
    indefinitely.

    estVals is the estimated number of states you expect the simulation
    to cycle through. This is used for pre-allocating array size for
    performance, but will not actually affect the accuracy of the
    simulation. Unused values are trimmed.

    heartbeat is a boolean logical input, where true enables a console
    log for each step finished, and false makes the program run silently.
    Enabling this likely slows down the program on smaller array sizes,
    but has a minimal impact on larger array sizes. A later revision
    will make this an integer that outputs a console log for each N steps

    saveVideo is a boolean logical input, if set to true, the simulation
    will create a NxNxM array of all states during the simulation and
    output it, this can be played back using the imagesc function.
    Turning this off means you will be unable to visualize your data, but
    surface area and volume calculations will still work. Turning this
    off also speeds up the code significantly. If disabled, the function
    will return an empty array for the states value

    mode is a string, specifying which of the three compute mode options
    to use for this simulation


OUTPUTS

    states is an NxNxM array, where N is the size provided earlier, and M
    is the number of states the simulation cycled through. Each slice in
    the Z direction represents the full state of the array. If saveVideo
    is set to false, this will instead return an empty array to shorten
    computation time.

    volume is an N length array, where each value is the sum of all cells
    in the array at that time, minus the volume of fixed cells, which is
    calculated by multiplying the sum of fixedMask by the defaultVal

    surfaceArea is an N length array, where each value represents the
    number of cells that have a value that rounds to the default value, 
    and a surrounding weight that rounds to less than 8 * default value.
    This effectively models the thrust of a solid rocket motor, although
    there is no consistent units, and thise values are only useful when
    compared to similar values from the same program.

    time is the total amount of real time that the simulation took to run,
    this does not represent the actual time the motor would take to burn.

Each calculateNeighborWeights function is effectively just a convolution function using different methods. I did not know the word convolution when I started this project, hence the naming. They should all have identical outputs given a uniform input set, save for floating point errors. They are all used by the stepState function, which is the main function behind the simulation itself. 

Finally, the two generateMask functions can be used to make simple masks to pass to the simulation. generateCircleMask is intended to be used for defining the edge geometry of the simulation, and your core, whereas the generateStarMask is intended for core geometry. If you write functions to generate more masks, please share them, I'd love to add them to this repository.

This is a university project, and comes with no support. I cannot guarantee I will continue working on this program at all, but I do have goals of creating a 3D version to model more complex core geometry. Helpful feedback is appreciated.
