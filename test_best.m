% Get the best
drawingSpecimen = bestSpecimen;

% Draw
draw_specimen

% Display
figure(1)
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 0.65, 0.5])
subplot(1,2,1)
imshow(originalImage)
subplot(1,2,2)
imshow(uint8(canvas))