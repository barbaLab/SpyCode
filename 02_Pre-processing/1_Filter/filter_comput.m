%%% filter_comput.m %%%
function [flag] = filter_comput(expFolder,outFolder,param)
% %%%
% verify if a MAT_ folder is present
folders = dir(expFolder);
folders = {folders.name};
start_folder = regexpi(folders,'.*Mat_files.*','match','once');
% indices of Mat_files names folders
idx = find(~strcmp(start_folder(:),''));
start_folder = start_folder(idx);
start_folder = char(start_folder);
foldNum = size(start_folder,1);
%
if foldNum == 0
    %     outputMessage=[outputMessage 'impossible to perform Peak Detection: no MAT_files folder is present'];
    flag = 0;
    return
elseif foldNum > 1
    %     outputMessage=[outputMessage 'impossible to perform Peak Detection: more than one MAT_files folder is present'];
    flag = 0;
    return
else
    start_folder = deblank(strcat(expFolder,filesep,start_folder)); %experiment folder
    % count number of different trials
    trialFolders = dirr(start_folder);
    numTrials = length(trialFolders);
    for j = 1:numTrials
        trialFolder = fullfile(start_folder,trialFolders(j).name);
        %     numberOfSamples = getSamplesNumber(trialFolder);
        [trialFolderPath, trialFolderName] = fileparts(trialFolder);
        try
            trialOutFolder = fullfile(outFolder,trialFolderName);
            if exist(trialOutFolder,'dir')
                rmdir(trialOutFolder,'s');
            end
            mkdir(trialOutFolder);
        catch
            errordlg(['Error creating ',trialOutFolder],'!!Error!!')
            flag = 0;
            return
        end
        numberOfElectrodes = getElectrodesNumber(trialFolder);
        files = dirr(trialFolder);
        for k = 1:numberOfElectrodes
            filename = fullfile(trialFolder,files(k).name);
            %         elecNumber = str2double(filename(end-5:end-4));
            load(filename);
            Wn_norm = param.cutOffFreq/(0.5*param.sf);
            [b,a]   = butter(2,Wn_norm,deblank(param.filterType));
            data    = double(int16(filter(b,a,data)));
            clear b a WN_norm;
            saveFilename = fullfile(trialOutFolder,files(k).name);
            try
                save(saveFilename,'data')
            catch
                errordlg(['Error saving ',saveFilename],'!!Error!!')
                flag = 0;
                return
            end
        end
    end
end
flag = 1;