%% Genetic figure
% Get the best
drawingSpecimen = bestSpecimen;

% Draw
draw_specimen

% Display
subplot(1,2,2)
imshow(uint8(canvas))
title(sprintf('Replicated image | Generation %05i',generation))
set(gca,'FontSize',16)