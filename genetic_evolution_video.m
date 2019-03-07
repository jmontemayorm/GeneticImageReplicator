%% Genetic evolution video
% Image for the video
imageIdx = 3;

% Load names
genetic_sources

% Output (and source) folder
if exist('getOutputFolder','file') == 2
    outF = getOutputFolder(mfilename('fullpath'));
else
    outF = pwd;
end

% Video writer
v = VideoWriter(fullfile(outF,imageNames{imageIdx},[imageNames{imageIdx} '.mp4']),'MPEG-4');
v.Quality = 100;
open(v)

% Initialize sequence
frameNumber = 1;
fileName = fullfile(outF,imageNames{imageIdx},'evolution',sprintf('%05i.png',frameNumber));

while exist(fileName,'file') == 2
    % Write to video
    writeVideo(v,imread(fileName));
    
    % Update frame number and fileName
    frameNumber = frameNumber + 1;
    fileName = fullfile(outF,sprintf('%s_evolution_%05i.png',imageNames{imageIdx},frameNumber));
end

close(v)
fprintf('The video file is ready.\n')