function [mask] = generateCircleMask(radius, sizeN, offsetX, offsetY)
% generateCircleMask creates a logical mask of a circle with radius, fitting
% inside a sizeN*sizeN array.
%   radius:   Radius of the circle (in pixels)
%   sizeN:    Size of the output mask (sizeN x sizeN)
%   offsetX:  Horizontal offset from center (positive = right)
%   offsetY:  Vertical offset from center (positive = down)

thetas = linspace(0, 2*pi, 250); % Angular sampling
x = cos(thetas) * radius + (sizeN/2 + offsetX); % Proper scaling and centering
y = sin(thetas) * radius + (sizeN/2 + offsetY);

mask = poly2mask(x, y, sizeN, sizeN);
end