% Get the best
drawingSpecimen = bestSpecimen;

% Draw
draw_specimen

% Display
figure(1)
subplot(1,2,1)
imshow(originalImage)
subplot(1,2,2)
imshow(uint8(canvas))