%% Draw specimen
% Empty canvas
canvas = blankCanvas;

% Loop through polygons
for row = 1:numOfPolygons
    % Extract data and convert to numeric
    x0 = drawingSpecimen(row, x0Idx) * multiplier((maxBits + 1 - xBits):end) + 1;
    xLen = drawingSpecimen(row, xLenIdx) * multiplier((maxBits + 1 - xLenBits):end);
    y0 = drawingSpecimen(row, y0Idx) * multiplier((maxBits + 1 - yBits):end) + 1;
    yLen = drawingSpecimen(row, yLenIdx) * multiplier((maxBits + 1 - yLenBits):end);
    color = drawingSpecimen(row, colorIdx) * multiplier((maxBits + 1 - colorBits):end);
    
    % Top X
    if x0 > maxX
        x0 = maxX;
    end
    
    % Top Y
    if y0 > maxY
        y0 = maxY;
    end
    
    % X index
    if x0 + xLen > maxX
        x = x0:maxX;
    else
        x = x0:(x0 + xLen);
    end
    
    % Y index
    if y0 + yLen > maxY
        y = y0:maxY;
    else
        y = y0:(y0 + yLen);
    end
    
    % Draw into canvas
    canvas(y,x) = canvas(y,x) + color;
end

% Flatten out canvas
canvas(canvas > 255) = 255;