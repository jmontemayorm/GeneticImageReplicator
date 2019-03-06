%% Draw specimen
% Empty canvas
canvas = blankCanvas;

% Loop through polygons
for row = 1:numOfPolygons
    % Extract data and convert to numeric
    x0 = drawingSpecimen(row, x0Idx) * multiplier8bits((9-xBits):end) + 1;
    xLen = drawingSpecimen(row, xLenIdx) * multiplier8bits((9-xLenBits):end);
    y0 = drawingSpecimen(row, y0Idx) * multiplier8bits((9-yBits):end) + 1;
    yLen = drawingSpecimen(row, yLenIdx) * multiplier8bits((9-yLenBits):end);
    c = drawingSpecimen(row, colorIdx);
    color = c * multiplier8bits((9-colorBits):end);
    
    % X index
    if x0 + xLen > 128
        x = x0:128;
    else
        x = x0:(x0 + xLen);
    end
    
    % Y index
    if y0 + yLen > 128
        y = y0:128;
    else
        y = y0:(y0 + yLen);
    end
    
    % Draw into canvas
    canvas(y,x) = canvas(y,x) + color;
end

% Flatten out canvas
canvas(canvas > 255) = 255;