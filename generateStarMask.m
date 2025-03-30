function [mask] = generateStarMask(innerRad,outerRad,sizeN,points,xOffset,yOffset)
% generateStarMask creates a logical mask of a star with 2 radii, fitting
% inside a sizeN*sizeN array.
%   radius:   Radius of the circle (in pixels)
%   sizeN:    Size of the output mask (sizeN x sizeN)
%   offsetX:  Horizontal offset from center (positive = right)
%   offsetY:  Vertical offset from center (positive = down)

pointRatio = outerRad/innerRad;

thetas = linspace(0, 2*pi, points+1); % Angular sampling
x = cos(thetas) * innerRad; % Proper scaling and centering
y = sin(thetas) * innerRad;

for i = 1:2:(points+1)
    x(i) = x(i)*pointRatio;
    y(i) = y(i)*pointRatio;
end

x = x + (sizeN/2) + xOffset;
y = y + (sizeN/2) + yOffset;

mask = poly2mask(x, y, sizeN, sizeN);
end