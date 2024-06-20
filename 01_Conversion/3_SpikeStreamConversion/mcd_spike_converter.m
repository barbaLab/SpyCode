clear all
%close all
clr
% %%%%
% Select the source folder
mcdFilesFolder = uigetdir(pwd,'Select the folder which contains the MCD files to convert');
if strcmp(num2str(mcdFilesFolder),'0')
    errordlg('Selection Failed - End of Session', 'Error');
    return
end 
% %%%%
% create output folder
PDFolder = createResultFolder(mcdFilesFolder, 'PeakDetectionMAT_MCRack');
if(isempty(PDFolder))
    return
end
% %%%%
% get parameters
[mcdSCParam, flag] = mcdSpikeConverter_getParam();
if(flag == 0)
    return
end
% %%%%
% [Files,Bytes,Names] = dirr('c:\matlab6p5\toolbox','\.mex\>','name')
[mcdFiles,bytes,mcdFileNames] = dirr(mcdFilesFolder,'\.mcd\>','name','isdir','0');
for ii = 1:length(mcdFileNames)
    [path,name] = fileparts(mcdFileNames{ii});
    curPhasePDFolderName = ['ptrain_' name];
    [S els artifact recDur sf successFlag] = CONV_mcd_data_sm(mcdFileNames{ii},mcdSCParam);
    if(~isempty(S) && successFlag == 1)
        mkdir(PDFolder, curPhasePDFolderName)
        curPhasePDFolder = fullfile(PDFolder,curPhasePDFolderName);
        for el = 1:length(els)
            spikesIdcs = S(:,1)==els(el);
            peak_train = sparse(round(nonzeros(S(spikesIdcs,2))),1,1,recDur,1);
%             peak_train = sparse(nonzeros(S(spikesIdcs,2)),1,1,recDur,1);
%             peak_train(S(spikesIdcs,2)) = S(spikesIdcs,3);
            save(fullfile(curPhasePDFolder,[curPhasePDFolderName '_' num2str(els(el))]),'peak_train','artifact');
        end
    else
        warning('No spikes found!') %#ok<WNTAG>
    end
end