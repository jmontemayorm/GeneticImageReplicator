%% Genetic replication of images
% This script attempts to replicate an image with polygons via a genetic
% algorithm.

%% Settings
% Image sources
% TODO: Put cell with names, loop through names, automate resize, change
% genes for the new resize
originalImage = rgb2gray(imresize(imread('Y.png'),0.5));

% Generations
enableMaxGenerations = 1;
maxGenerations = 20000;

% Timeout
enableTimeout = 1;
timeoutMinutes = 5;

% Fitness
enanleFitnessBreak = 0;
fitnessBreak = 0.00001;

% Console output
suppressOutput = 0;
modulateOutput = 0;
outputModulation = 100;

% Elitism
enableElitism = 0;
elitismFraction = 0.2;

% Save (file)
enableSave = 0;
saveModulation = 100;

% Population
populationSize = 100;

% Specimen
numOfPolygons = 100;
x0Idx = 1:7;
xLenIdx = 8:13;
y0Idx = 14:20;
yLenIdx = 21:26;
colorIdx = 27:34;
geneSize = 34;
multiplier8bits = 2 .^ (7:-1:0)';
multiplier7bits = 2 .^ (6:-1:0)';
multiplier6bits = 2 .^ (5:-1:0)';

% Cooldown
enableCooldown = 1;
cooldownModulation = 1000;
cooldownSeconds = 20;

%% Calculated settings
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

% Warnings
if enableMaxGenerations == 0 && enableTimeout == 0 && enanleFitnessBreak == 0
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

if suppressOutput == 0 && modulateOutput == 1
    warning('Evolution output logs will be modulated to every %i generations.',outputModulation);
elseif suppressOutput == 1
    warning('No logs will be generated during the evolution process.');
end

tic
generation = 1;
bestFitness = 0;

while true % Breaking conditions found before updating the counter
    % Calculate if there will be output in this generation
    printToConsole = suppressOutput == 0 && (modulateOutput == 0 || (modulateOutput == 1 && mod(generation,outputModulation) == 0));
    
    % % % Evaluation % % %
    % Generate artworks from current population
    if printToConsole
        fprintf('Drawing generation number %04i... ',generation);
    end
    for specimen = 1:populationSize
        % Create an empty canvas to draw the polygons
        canvas = zeros(size(originalImage));
        
        for row = 1:numOfPolygons
            % Extract data and convert to numeric
            x0 = theLiving{specimen}(row, x0Idx) * multiplier7bits + 1;
            xLen = theLiving{specimen}(row, xLenIdx) * multiplier6bits;
            y0 = theLiving{specimen}(row, y0Idx) * multiplier7bits + 1;
            yLen = theLiving{specimen}(row, yLenIdx) * multiplier6bits;
            color = theLiving{specimen}(row, colorIdx) * multiplier8bits;
            
            % X index
            if x0 + xLen > 128
                x = x0:128;
            else
                x = x0:(x0 + xLen);
            end
            
            % Y index
            if y0 + yLen > 128
                y = y0:128;
            else
                y = y0:(y0 + yLen);
            end
            
            % Draw into canvas
            canvas(y,x) = canvas(y,x) + color;
        end
        
        % Flatten out canvas
        canvas(canvas > 255) = 255;
        
        % Evaluate mismatch
        artworkMismatch(specimen) = sum(sum(abs(canvas - double(originalImage))));
    end
    if printToConsole
        fprintf('Done!\n');
    end
    
    % Get fitness
    specimenFitness = 1 ./ artworkMismatch;
    [~,bestIdx] = sort(specimenFitness);
    if printToConsole
        fprintf('\tBest fitness in this generation is: %0.7f\n',specimenFitness(bestIdx(1)));
    end
    
    % Check and save (RAM) the all-time best
    if specimenFitness(bestIdx(1)) >= bestFitness
        bestFitness = specimenFitness(bestIdx(1));
        bestSpecimen = theLiving{bestIdx(1)};
    end
    
    % % % Save the best in the generation % % %
    if enableSave == 1 && mod(generation,saveModulation) == 0
       bestOfGen = theLiving{bestIdx(1)};
       save(fullfile(outF,sprintf('ImageBestOfGen_%07i.mat',generation)),'bestOfGen');
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
            for candidate = populationIndices(allowedIdx)
                if rand < 0.4 % Equal probability, give a bias to fittest via order?
                    lookingForFirstParent = false;
                    firstParentIdx = candidate;
                    allowedIdx(firstParentIdx) = false;
                    break
                end
            end
        end
        
        % Get second parent
        secondParentIdx = 0;
        lookingForSecondParent = true;
        while lookingForSecondParent
            for candidate = populationIndices(allowedIdx)
                if rand < 0.4 % Equal probability, give a bias to fittest via order?
                    lookingForSecondParent = false;
                    secondParentIdx = candidate;
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
        mutate = rand(numOfPolygons, geneSize) < 0.2;
        theLiving{specimen}(mutate) = ~theLiving{specimen}(mutate);
    end
    
    % % % Breaking mechanisms % % %
    % Break when achieving max generation
    if (enableMaxGenerations == 1 && generation == maxGenerations)
        break;
    end
    
    % Break when achieving fitness
    if (enanleFitnessBreak == 1 && bestFitness >= fitnessBreak)
        break;
    end
    
    % Break when achieving timeout
    if (enableTimeout == 1 && toc >= timeout)
        break;
    end
    
    % Cooldown
    if enableCooldown == 1 && mod(generation,cooldownModulation) == 0
        pause(cooldownSeconds);
    end
    
    % Go to the next generation
    generation = generation + 1;
end

elapsedTime = toc;
toc

fprintf('Evolution sequence complete. Achieved generation %04i!\n',generation);