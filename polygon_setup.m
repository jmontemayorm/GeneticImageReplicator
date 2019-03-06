%% Polygon setup
xBits = 7;
yBits = 7;
xLenBits = 4;
yLenBits = 4;
colorBits = 8;

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

% Multipliers
multiplier8bits = 2 .^ (7:-1:0)';