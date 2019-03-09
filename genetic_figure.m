%% Genetic figure
% Empty canvas
canvas = blankCanvas;

% Extract data
polygons = bestSpecimen * multiplier;

% Start indices at 1
polygons(:,1:4) = polygons(:,1:4) + 1;

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

% Display
subplot(1,2,2)
imshow(uint8(canvas))
title(sprintf('Replicated image | Generation %05i',generation))
set(gca,'FontSize',16)