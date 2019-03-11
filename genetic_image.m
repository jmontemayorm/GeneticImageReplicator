%% Genetic replication of images
% This script attempts to replicate an image with polygons via a genetic
% algorithm.

%% Settings
% Image index (see genetic_sources for details)
imageIdx = 2;

% Generations
enableMaxGenerations = 1;
maxGenerations = 20000;

% Timeout
enableTimeout = 0;
timeoutMinutes = 10;

% Fitness
enableFitnessBreak = 0;
fitnessBreak = 0.00001;

% Stall
enableStallBreak = 1;
stallBreak = 5000;

% Console output
suppressOutput = 0;
modulateOutput = 1;
outputModulation = 100;

% Save checkpoint (.mat file with the whole population)
enableCheckpoint = 1;
checkpointModulation = 5000;

% Start from checkpoint
startFromCheckpoint = 0;
checkpointNumber = 1;

% Save image evolution (when fitness improves)
enableSaveEvolution = 1;

% Elitism
enableElitism = 1;
elitismFraction = 0.1;

% Population
populationSize = 100;

% Specimen
numOfPolygons = 1000;
reducedLengthBits = 3;

paternalProbability = 0.6;
mutationProbability = 0.0001;

startWithBlackCanvas = 1;

% Cooldown
enableCooldown = 1;
cooldownModulation = 1000;
cooldownSeconds = 15;

%% Calculated settings
% Load image and setup polygons (gene info)
genetic_sources
if imageRGB{imageIdx} == 1
    originalImage = imresize(imread([imageNames{imageIdx} imageExtensions{imageIdx}]),imageResizeFactor{imageIdx});
    totalNumOfPixels = size(originalImage,1) * size(originalImage,2) * size(originalImage,3);
else
    originalImage = rgb2gray(imresize(imread([imageNames{imageIdx} imageExtensions{imageIdx}]),imageResizeFactor{imageIdx}));
    totalNumOfPixels = size(originalImage,1) * size(originalImage,2);
end
genetic_polygon_setup

% Timeout
timeout = timeoutMinutes * 60;

% Elitism
if enableElitism == 0
    elitismFraction = 0;
end
eliteAmount = floor(populationSize * elitismFraction);
nonEliteIdx = (eliteAmount + 1):populationSize;

% Output folder
if exist('getOutputFolder','file') == 2
    outF = getOutputFolder(mfilename('fullpath'));
else
    outF = pwd;
end

progressFolder = fullfile(imageNames{imageIdx},'evolution');
if enableSaveEvolution == 1 && exist(fullfile(outF,progressFolder),'dir') ~= 7
    if mkdir(fullfile(outF,progressFolder)) ~= 1
        progressFolder = '';
    end
end

% Warnings
if enableMaxGenerations == 0 && enableTimeout == 0 && enableFitnessBreak == 0 && enableStallBreak == 0
    error('At least one method of breaking the loop is required.');
elseif enableMaxGenerations == 0 && enableTimeout == 0 && enableStallBreak == 0
    warning('The loop will only break if the desired fitness is achieved. Achieving the fitness is not guaranteed.');
    executionOverride = input('Continue execution?\n','s');
    if ~isempty(executionOverride) && (executionOverride(1) == 'y' || executionOverride(1) == 'Y')
        fprintf('Execution override successful.\n');
    else
        error('Execution stoped. Please change the parameters or override execution.');
    end
end

if suppressOutput == 0 && modulateOutput == 1
    warning('Evolution output logs will be modulated to every %i generations.',outputModulation);
elseif suppressOutput == 1
    warning('No logs will be generated during the evolution process.');
end

%% Initial population
fprintf('Initializing population... ');

% Allocate memory
theLiving = cell(populationSize,1);
artworkMismatch = zeros(populationSize,1);

% Randomize population
for specimen = 1:populationSize
    theLiving{specimen} = randi([0, 1], [numOfPolygons, geneSize]);
    
    % Black canvas
    if startWithBlackCanvas == 1
        theLiving{specimen}(:,colorIdx) = 0;
        if imageRGB{imageIdx} == 1
            theLiving{specimen}(:,colorIdx2) = 0;
            theLiving{specimen}(:,colorIdx3) = 0;
        end
    end
end

fprintf('Done!\n');

%% Evolution
fprintf('Starting evolution process...\n\n');

generation = 1;
savedImageNumber = 1;
bestFitness = 0;

% Load checkpoint, if selected
if startFromCheckpoint == 1
    checkpointFileName = fullfile(outF,sprintf('Checkpoint_%s_%05i.mat',imageNames{imageIdx},checkpointNumber));
    
    % Validate checkpoint
    if exist(checkpointFileName,'file') == 2
        load(checkpointFileName);
    else
        warning('The selected checkpoint was not found.');
        executionOverride = input('Continue execution from scratch?\n','s');
        if ~isempty(executionOverride) && (executionOverride(1) == 'y' || executionOverride(1) == 'Y')
            fprintf('Execution override successful.\n');
        else
            error('Execution stoped. Please change the parameters or override execution.');
        end
    end
end

tic
bestGeneration = generation;
blankCanvas = zeros(size(originalImage),'uint8');

genetic_figure_setup

while true % Breaking conditions found before updating the counter
    % Calculate if there will be console output in this generation
    printToConsole = suppressOutput == 0 && (modulateOutput == 0 || (modulateOutput == 1 && mod(generation,outputModulation) == 0));
    
    % % % Evaluation % % %
    % Generate artworks from current population
    if printToConsole
        fprintf('Drawing generation number %05i... ',generation);
    end
    for specimen = 1:populationSize        
        % Get canvas
        genetic_canvas
        
        % Evaluate mismatch
        if imageRGB{imageIdx} == 1
            artworkMismatch(specimen) = sum(sum(sum(abs(double(canvas) - double(originalImage))))) / totalNumOfPixels;
        else
            artworkMismatch(specimen) = sum(sum(abs(double(canvas) - double(originalImage)))) / totalNumOfPixels;
        end
    end
    if printToConsole
        fprintf('Done!\n');
    end
    
    % Get fitness
    specimenFitness = 1 ./ artworkMismatch;
    [~,bestIdx] = sort(specimenFitness,'descend');
    if printToConsole
        fprintf('\tBest fitness in this generation is: %0.8f\n',specimenFitness(bestIdx(1)));
    end
    
    % Check and save (RAM) the all-time best
    if specimenFitness(bestIdx(1)) >= bestFitness
        % Save the data into memory
        bestFitness = specimenFitness(bestIdx(1));
        bestSpecimen = theLiving{bestIdx(1)};
        bestGeneration = generation;
        
        % Get canvas
        specimen = bestIdx(1);
        genetic_canvas
        
        % Display
        subplot(1,2,2)
        imshow(canvas)
        title(sprintf('Replicated image | Generation %05i',generation))
        set(gca,'FontSize',16)
        
        % Pause to update display
        pause(0)
        
        % Save progress image
        if enableSaveEvolution == 1
            saveas(f,fullfile(outF,progressFolder,sprintf('%05i.png',savedImageNumber)),'png')
            savedImageNumber = savedImageNumber + 1;
        end
    end
    
    % % % Survival of the fittest % % %
    % Acquire targets
    killed = 0;
    killIdx = false(1,populationSize);
    while killed < populationSize / 2
        % Go from unfittest to fittest
        unfitToFit = flip(bestIdx(nonEliteIdx)); % Only the non elite
        
        for s = 1:(populationSize - eliteAmount)
            specimen = unfitToFit(s);
            % Always include probability of survival (also for unfittest, elitism exception)
            if (killIdx(specimen) == false) && (exp(find(specimen == bestIdx,1)/populationSize - 1.1) >= rand)
                % Acquire target
                killIdx(specimen) = true;
                
                % Increase counter and check
                killed = killed + 1;
                if killed >= populationSize / 2
                    break
                end
            end
        end
    end
    
    % Kill and substitute via reproduction
    replaceWithBaby = find(killIdx);
    for newBaby = 1:length(replaceWithBaby)
        % Only search in the ones not to be killed
        allowedIdx = ~killIdx;
        
        % Get first parent
        firstParentIdx = 0;
        lookingForFirstParent = true;
        while lookingForFirstParent
            % The most fit are the firsts in line
            orderedCandidatesIdx = bestIdx(allowedIdx);
            
            for candidate = 1:length(orderedCandidatesIdx)                
                if rand < paternalProbability
                    lookingForFirstParent = false;
                    firstParentIdx = orderedCandidatesIdx(candidate);
                    allowedIdx(firstParentIdx) = false;
                    break
                end
            end
        end
        
        % Get second parent
        secondParentIdx = 0;
        lookingForSecondParent = true;
        while lookingForSecondParent
            % The most fit are the firsts in line
            orderedCandidatesIdx = bestIdx(allowedIdx);
            
            for candidate = 1:length(orderedCandidatesIdx)
                if rand < paternalProbability
                    lookingForSecondParent = false;
                    secondParentIdx = orderedCandidatesIdx(candidate);
                    break
                end
            end
        end
        
        % Make baby
        firstParent = randi([0, 1], [numOfPolygons, 1]);
        secondParent = ~firstParent;
        theLiving{replaceWithBaby(newBaby)} = firstParent .* theLiving{firstParentIdx} + secondParent .* theLiving{secondParentIdx};
    end
    
    % % % Mutations % % %
    for specimen = 1:populationSize
        mutate = rand(numOfPolygons, geneSize) < mutationProbability;
        theLiving{specimen}(mutate) = ~theLiving{specimen}(mutate);
    end
    
    % % % Save the living as checkpoint % % %
    if enableCheckpoint == 1 && mod(generation,checkpointModulation) == 0
       save(fullfile(outF,sprintf('Checkpoint_%s_%05i.mat',imageNames{imageIdx},generation)),'theLiving','generation','savedImageNumber','bestFitness');
       fprintf('Saved checkpoint.\n');
    end
    
    % % % Breaking mechanisms % % %
    % Break when achieving max generation
    if (enableMaxGenerations == 1 && generation == maxGenerations)
        break
    end
    
    % Break when achieving fitness
    if (enableFitnessBreak == 1 && bestFitness >= fitnessBreak)
        break
    end
    
    % Break when achieving timeout
    if (enableTimeout == 1 && toc >= timeout)
        break
    end
    
    % Break when stalled progress
    if (enableStallBreak == 1 && generation - bestGeneration == stallBreak)
        break
    end
    
    % Cooldown
    if enableCooldown == 1 && mod(generation,cooldownModulation) == 0
        pause(cooldownSeconds)
    end
    
    % Go to the next generation
    generation = generation + 1;
end

elapsedTime = toc;
toc

fprintf('Evolution sequence complete. Achieved generation %05i!\n',generation);
