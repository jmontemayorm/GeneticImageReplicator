%% Genetic replication of images
% This script attempts to replicate an image with polygons via a genetic
% algorithm.

%% Settings
% Image index (see genetic_sources for details)
imageIdx = 3;

% Generations
enableMaxGenerations = 1;
maxGenerations = 20;

% Timeout
enableTimeout = 0;
timeoutMinutes = 10;

% Fitness
enableFitnessBreak = 0;
fitnessBreak = 0.00001;

% Console output
suppressOutput = 1;
modulateOutput = 1;
outputModulation = 100;

% Save checkpoint (.mat file with the whole population)
enableCheckpoint = 0;
checkpointModulation = 5000;

% Save image evolution (when fitness improves)
enableSaveEvolution = 0;

% Elitism
enableElitism = 1;
elitismFraction = 0.1;

% Population
populationSize = 100;

% Specimen
numOfPolygons = 5000;
reducedLengthBits = 3;

paternalProbability = 0.6;
mutationProbability = 0.00001;

% Cooldown
enableCooldown = 0;
cooldownModulation = 50;
cooldownSeconds = 10;

%% Calculated settings
% Load image and setup polygons (gene info)
genetic_sources
originalImage = rgb2gray(imread([imageNames{imageIdx} imageExtensions{imageIdx}]));
polygon_setup

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
if enableMaxGenerations == 0 && enableTimeout == 0 && enableFitnessBreak == 0
    error('At least one method of breaking the loop is required.');
elseif enableMaxGenerations == 0 && enableTimeout == 0
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
theLiving = cell(populationSize,1);
artworkMismatch = zeros(populationSize,1);
populationIndices = 1:populationSize;
for specimen = 1:populationSize
    theLiving{specimen} = randi([0, 1], [numOfPolygons, geneSize]);
end
fprintf('Done!\n');

%% Evolution
fprintf('Starting evolution process...\n\n');

tic
generation = 1;
savedImageNumber = 1;
bestFitness = 0;
blankCanvas = zeros(size(originalImage),'uint8');

setup_genetic_figure

while true % Breaking conditions found before updating the counter
    % Calculate if there will be console output in this generation
    printToConsole = suppressOutput == 0 && (modulateOutput == 0 || (modulateOutput == 1 && mod(generation,outputModulation) == 0));
    
    % % % Evaluation % % %
    % Generate artworks from current population
    if printToConsole
        fprintf('Drawing generation number %05i... ',generation);
    end
    for specimen = 1:populationSize
        % Get the specimen to draw
        drawingSpecimen = theLiving{specimen};
        
        % Draw
        draw_specimen
        
        % Evaluate mismatch
        artworkMismatch(specimen) = sum(sum(abs(double(canvas) - double(originalImage))));
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
    if specimenFitness(bestIdx(1)) > bestFitness
        % Save the data into memory
        bestFitness = specimenFitness(bestIdx(1));
        bestSpecimen = theLiving{bestIdx(1)};
        
        % Plot
        genetic_figure
        pause(0)
        
        % Save progress image
        if enableSaveEvolution == 1
            saveas(f,fullfile(outF,progressFolder,sprintf('%05i.png',savedImageNumber)),'png')
            savedImageNumber = savedImageNumber + 1;
        end
    end
    
    % % % Save the living as checkpoint % % %
    if enableCheckpoint == 1 && mod(generation,checkpointModulation) == 0
       save(fullfile(outF,sprintf('ImageBestOfGen_%07i.mat',generation)),'theLiving');
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
    
    % Cooldown
    if enableCooldown == 1 && mod(generation,cooldownModulation) == 0
        pause(cooldownSeconds)
    end
    
    % Go to the next generation
    generation = generation + 1;
end

elapsedTime = toc;
toc

fprintf('Evolution sequence complete. Achieved generation %04i!\n',generation);