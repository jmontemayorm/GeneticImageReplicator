%% Genetic replication of images

%% Layout
% color intensity = 8 bytes = 64 bits per color

%% Settings
% General settings
activateMaxGenerations = 1;
maxGenerations = 100;

activateTimeout = 0;
timeoutMinutes = 5;

activateFitnessBreak = 0;
fitnessBreak = 100;

% Population settings
populationSize = 30; % Must be an even number, better if multiple of cores used

% Specimen settings
bitsPerColor = 64;

% Parallel settings
maxWorkers = 6;

% Calculated settings
timeout = timeoutMinutes * 60;

% Settings warnings
if activateMaxGenerations == 0 && activateTimeout == 0 && activateFitnessBreak == 0
    error('At least one method of breaking the loop is required.');
elseif activateMaxGenerations == 0 && activateTimeout == 0
    warning('The loop will only break if the desired fitness is achieved. Achieving the fitness is not guaranteed.');
    executionOverride = input('Continue execution?\n','s');
    if ~isempty(executionOverride) && (executionOverride(1) == 'y' || executionOverride(1) == 'Y')
        fprintf('Execution override successful.\n');
    else
        error('Execution stoped. Please change the parameters or override execution.');
    end
end

%% MAIN LOOP IN CONSTRUCTION
tic
generation = 1;

% Breaking conditions found before updating the counter
while true
    
    % get bestFitness
    
    % Break when achieving max generation
    if activateMaxGenerations == 1 && generation == maxGenerations
        break;
    end
    
    % Break when achieving fitness
    if activateFitnessBreak == 1 && bestFitness >= fitnessBreak
        break;
    end
    
    % Break when achieving timeout
    if activateTimeout == 1 && toc >= timeout
        break;
    end
    
    % Go to the next generation
    generation = generation + 1;
end

elapsedTime = toc;
