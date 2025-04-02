function [mask] = generateHexagonalMask(radius, sizeN, xOffset, yOffset)
% generateHexagonalMask creates a logical mask of a hexagon, fitting
% inside a sizeN*sizeN array.
%   radius:   Radius of the hexagon (distance from center to a vertex)
%   sizeN:    Size of the output mask (sizeN x sizeN)
%   xOffset:  Horizontal offset from center (positive = right)
%   yOffset:  Vertical offset from center (positive = down)

% Define the 6 angles of the hexagon's vertices (in radians)
thetas = linspace(0, 2*pi, 7);  % We use 7 to close the hexagon loop (last point is same as first)

% Coordinates of the vertices of the hexagon
x = cos(thetas) * radius;
y = sin(thetas) * radius;

% Apply offset and center the hexagon in the sizeN x sizeN mask
x = x + (sizeN / 2) + xOffset;
y = y + (sizeN / 2) + yOffset;

% Create the mask using poly2mask, which generates a binary mask from the vertices
mask = poly2mask(x, y, sizeN, sizeN);
end
