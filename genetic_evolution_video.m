%% Genetic evolution video
% Image for the video
imageIdx = 3;

% Max frames at a time
maxFrames = 200;

% Load names
genetic_sources

% Output (and source) folder
if exist('getOutputFolder','file') == 2
    outF = getOutputFolder(mfilename('fullpath'));
else
    outF = pwd;
end

% Initialize sequence
frameNumber = 1;
fileName = fullfile(outF,imageNames{imageIdx},'evolution',sprintf('%05i.png',frameNumber));

% Count number of frames
while exist(fileName,'file') == 2
    % Update frame number and fileName
    frameNumber = frameNumber + 1;
    fileName = fullfile(outF,imageNames{imageIdx},'evolution',sprintf('%05i.png',frameNumber));
end

totalFrames = frameNumber - 1;

% Check if no frames were found
if totalFrames == 0
    error('No frames for %s were found.',imageNames{imageIdx});
end

fprintf('Counted %i images in the directory.\n',totalFrames)

% Reset file name
frameNumber = 1;
fileName = fullfile(outF,imageNames{imageIdx},'evolution',sprintf('%05i.png',frameNumber));

fprintf('Reading frames and writing to video...')
% Read first image to allocate memory (write max 100 frames at a time)
firstImage = imread(fileName);
if totalFrames < maxFrames
    frames = uint8(zeros([size(firstImage) totalFrames]));
else
    frames = uint8(zeros([size(firstImage) maxFrames]));
end

% Reset frame number
frameNumber = 0;

% Video writer
v = VideoWriter(fullfile(outF,imageNames{imageIdx},[imageNames{imageIdx} '.mp4']),'MPEG-4');
v.Quality = 100;
open(v)

% Initializes progress bar
waitB = waitbar(0,sprintf('Generating video... %d%%',0));

% Loop through batches
for batch = 1:floor(totalFrames/maxFrames)
    for frame = 1:maxFrames
        frameNumber = frameNumber + 1;
        fileName = fullfile(outF,imageNames{imageIdx},'evolution',sprintf('%05i.png',frameNumber));
        
        frames(:,:,:,frame) = imread(fileName);
    end
    
    writeVideo(v,frames);
    
    perc = frameNumber / totalFrames;
    waitbar(perc,waitB,sprintf('Generating video... %d%%',round(perc*100)))
end

% Write the remaining batch
remaining = mod(totalFrames,maxFrames);
if remaining ~= 0
    frames(:,:,:,(remaining+1):end) = [];
    
    for frame = 1:remaining
        frameNumber = frameNumber + 1;
        fileName = fullfile(outF,imageNames{imageIdx},'evolution',sprintf('%05i.png',frameNumber));
        
        frames(:,:,:,frame) = imread(fileName);
    end
    
    writeVideo(v,frames);
    perc = frameNumber / totalFrames;
    waitbar(perc,waitB,sprintf('Generating video... %d%%',round(perc*100)))
end
fprintf(' Done!\n')

close(v)
close(waitB)
fprintf('The video file is ready.\n')