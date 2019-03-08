%% Polygon setup
% Maximum bits per color
colorBits = 8;

% Extract the size of the image
imageSize = size(originalImage);
maxX = imageSize(2);
maxY = imageSize(1);

% Get the necessary number of bits
xBits = ceil(log2(maxX));
yBits = ceil(log2(maxY));

% Maximum size of the squares, with reduced bits
xLenBits = xBits - reducedLengthBits;
yLenBits = yBits - reducedLengthBits;

% Ensure at least 3 bits for length
if xLenBits < 3
    xLenBits = 3;
end
if yLenBits < 3
    yLenBits = 3;
end

% Polygon indices
idxCounter = 1;

x0Idx = idxCounter:xBits;
idxCounter = x0Idx(end) + 1;

xLenIdx = idxCounter:(idxCounter - 1 + xLenBits);
idxCounter = xLenIdx(end) + 1;

y0Idx = idxCounter:(idxCounter - 1 + yBits);
idxCounter = y0Idx(end) + 1;

yLenIdx = idxCounter:(idxCounter - 1 + yLenBits);
idxCounter = yLenIdx(end) + 1;

colorIdx = idxCounter:(idxCounter - 1 + colorBits);

% Full polygon gene size
geneSize = colorIdx(end);

% Generate matrix multiplier
multiplier = zeros(geneSize,5);

multiplier(x0Idx,1) = 2 .^ ((xBits - 1):-1:0)';

multiplier(x0Idx,2) = 2 .^ ((xBits - 1):-1:0)';
multiplier(xLenIdx,2) = 2 .^ ((xLenBits - 1):-1:0)';

multiplier(y0Idx,3) = 2 .^ ((yBits - 1):-1:0)';

multiplier(y0Idx,4) = 2 .^ ((yBits - 1):-1:0)';
multiplier(yLenIdx,4) = 2 .^ ((yLenBits - 1):-1:0)';

multiplier(colorIdx,5) = 2 .^ ((colorBits - 1):-1:0)';