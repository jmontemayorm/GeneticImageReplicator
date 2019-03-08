%% Draw specimen
% Empty canvas
canvas = blankCanvas;

% Extract data
polygons = drawingSpecimen * multiplier;

% Up start points (will be used as indices)
polygons(:,1) = polygons(:,1) + 1;
polygons(:,2) = polygons(:,2) + 1;
polygons(:,3) = polygons(:,3) + 1;
polygons(:,4) = polygons(:,4) + 1;

% Top X start
polygons(polygons(:,1) > maxX, 1) = maxX;
% Top X end
polygons(polygons(:,2) > maxX, 2) = maxX;
% Top Y start
polygons(polygons(:,3) > maxY, 3) = maxY;
% Top Y end
polygons(polygons(:,4) > maxY, 4) = maxY;

% Loop through polygons
for p = 1:numOfPolygons
    canvas(polygons(p,3):polygons(p,4),polygons(p,1):polygons(p,2)) = canvas(polygons(p,3):polygons(p,4),polygons(p,1):polygons(p,2)) + uint8(polygons(p,5));
end