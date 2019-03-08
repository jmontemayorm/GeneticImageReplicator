function OUTFOLDER = getOutputFolder(WORKINGFILE)
    %GETOUTPUTFOLDER Returns a folder 'Output' within WORKINGFILE.
    %   If it does not exist, it creates a folder named 'Output' inside
    %   WORKINGFILE.
    %
    %   GETOUTPUTFOLDER(mfilename('fullpath')) creates a folder (if it
    %   doesn't exist) 'Output' in the directory where the file making the
    %   call is located and returns the path, which then can be used along
    %   fullfile to create files inside the folder.
    
    %   Author: Javier Montemayor Mancias
    %   Created on: 2019.01.23
    %   Last updated: 2019.01.24
    %   Version: v1.0
    
    % Folder of the current path
    charIdx = strfind(WORKINGFILE,'/');
    if isempty(charIdx)
        charIdx = strfind(WORKINGFILE,'\');
    end
    workingFolder = '';
    if ~isempty(charIdx)
        workingFolder = extractBefore(WORKINGFILE,charIdx(end));
    end
    if isempty(workingFolder)
        workingFolder = pwd;
    end

    if exist(fullfile(workingFolder,'Output'),'dir') == 7
        OUTFOLDER = fullfile(workingFolder,'Output');
    else
        if mkdir(workingFolder,'Output') == 1
            OUTFOLDER = fullfile(workingFolder,'Output');
        else
            OUTFOLDER = '';
        end
    end
end