function replaceArtefact_comput(actualFolder,replaceArtParam)
% %%%
folders = dir(actualFolder);
folders = {folders.name};
PDfolder = regexpi(folders,'.*PeakDetectionMAT.*','match','once');
ANAfolder = regexpi(folders,'.*Ana_files.*','match','once');
PDfolder = char(PDfolder(~strcmp(PDfolder(:),'')));
ANAfolder = char(ANAfolder(~strcmp(ANAfolder(:),'')));
PDfoldNum = size(PDfolder,1);
ANAfoldNum = size(ANAfolder,1);
% %%%
if (PDfoldNum == 0 || ANAfoldNum == 0) || (PDfoldNum > 1 || ANAfoldNum > 1)
    return
else
    PDfolder2 = strcat(PDfolder,'2');
    mkdir(actualFolder,PDfolder2)
    PDfolder2 = fullfile(actualFolder,PDfolder2);
    PDfolder = fullfile(actualFolder,PDfolder);
    ANAfolder = fullfile(actualFolder,ANAfolder);
    all_phases = dir(PDfolder);
    all_phases = {all_phases.name};
    stimPhasesFolders = regexpi(all_phases,'.*stim.*','match','once');
    stimPhasesFolders = char(stimPhasesFolders(~strcmp(stimPhasesFolders(:),'')));
    for p = 1:size(stimPhasesFolders,1)
        mkdir(PDfolder2,stimPhasesFolders(p,:));
        this_phase = strtrim(stimPhasesFolders(p,8:end));
        fprintf('\n%s: ',this_phase);
        prevWorkDir = pwd;
        cd([PDfolder,filesep,stimPhasesFolders(p,:)])
        peak_files = dir;
        cd(prevWorkDir)
        stim_artifact = find_artefacts_analogRawData(fullfile(ANAfolder,[this_phase, filesep, this_phase '_A.mat']),replaceArtParam.minArtAmpl);
        for pf = 3:length(peak_files);
            fprintf('.');
            clear artifact peak_train;
            prevWorkDir = pwd;
            cd([PDfolder,filesep,stimPhasesFolders(p,:)])
            load(peak_files(pf).name);
            artifact = stim_artifact(:);
            cd(fullfile(PDfolder2,stimPhasesFolders(p,:)))
            save(peak_files(pf).name,'artifact','peak_train')
            cd(prevWorkDir)
        end
    end
end
end