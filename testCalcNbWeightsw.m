%Compare performance of the vectorized and loop versions of
%calculateNeighborWeights

%Generate a magic matrix to test with

tic

size = 5000;
imax = 5;

%testval = magic(size);
testval = imax * rand(size, 'gpuArray');

magictime = toc;

%Non vectorised time

tic

nonvecres = calculateNeighborWeights(testval,5);

nonvectime = toc;

%Vectorized time

tic

vecres = calculateNeighborWeightsVec(testval,5);

vectime = toc;

%GPU Accelerated time

tic

gpures = calculateNeighborWeightsGPU(testval,5);

gputime = toc;

fprintf("Took %0.4f seconds to generate sample array of size %d.\n",magictime,size)
fprintf("Non Vectorized version took %0.4f seconds.\n",nonvectime)
fprintf("Vectorized version took %0.4f seconds.\n",vectime)
fprintf("GPU version took %0.4f seconds.\n",gputime)
