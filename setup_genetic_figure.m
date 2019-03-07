%% Setup of the original image
% Get a figure
f = figure(1);

% Set window size, background color
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 0.65, 0.5])
set(gcf,'Color','w')

% Subplot the original
subplot(1,2,1)
imshow(originalImage)
title('Original image')
set(gca,'FontSize',16)

% Put the title of the replica
subplot(1,2,2)
imshow(uint8(255*ones(size(originalImage))))
title('Replicated image')
set(gca,'FontSize',16)

% Apply draw
pause(1)