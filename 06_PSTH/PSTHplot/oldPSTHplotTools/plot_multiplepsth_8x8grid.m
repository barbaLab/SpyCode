% PLOT_PSTH_8x8grid.m
% Multiple plot for PSTH files CHECK ALWAYS!!!! It must be changed
% To be modified: maximum of the PSTH plot (not known a priori) ----

% by Michela Chiappalone (31 gennaio 2006)

clr
% Select the source and target folder
[start_folder]= selectfolder('Select the source folder that contains the PSTH files'); %The foldername contains the binsize
if strcmp(num2str(start_folder),'0')
    errordlg('Selection Failed - End of Session', 'Error');
    return
end
end_folder = uigetdir(pwd,'Select the PSTHresults folder');
if strcmp(num2str(end_folder),'0')
    errordlg('Selection Failed - End of Session', 'Error');
    return
end

% Create the end_folder that will contain the 8x8plots of the PSTH
[exp_num]=find_expnum(start_folder, '_PSTHfiles');
[end_folder]=createresultfolder(end_folder, exp_num, 'PSTH_plot8x8grid');

% --------------- USER information
prompt  = {'Number of test stimulus session:', 'PSTH time frame to display (msec)'};         
title   = 'Plot multiple PSTH settings';
lines   = 1;
def     = {'1', '400'};
Ianswer = inputdlg(prompt,title,lines,def);
num_stimel= str2num(Ianswer{1,1});    % Number of test stimulus session
psthend=  str2double(Ianswer{2,1});   % Timeframe of the PSTH plot (X-axis)
if  isempty(num_stimel)
    display ('End Of Function')
    return
end
clear title prompt lines def

% --------------- MEA variables
lookuptable= [  11  1; 21  2; 31  3; 41  4; 51  5; 61  6; 71  7; 81  8; ...
                12  9; 22 10; 32 11; 42 12; 52 13; 62 14; 72 15; 82 16; ...
                13 17; 23 18; 33 19; 43 20; 53 21; 63 22; 73 23; 83 24; ...
                14 25; 24 26; 34 27; 44 28; 54 29; 64 30; 74 31; 84 32; ...
                15 33; 25 34; 35 35; 45 36; 55 37; 65 38; 75 39; 85 40; ...
                16 41; 26 42; 36 43; 46 44; 56 45; 66 46; 76 47; 86 48; ...
                17 49; 27 50; 37 51; 47 52; 57 53; 67 54; 77 55; 87 56; ...
                18 57; 28 58; 38 59; 48 60; 58 61; 68 62; 78 63; 88 64];
 mcmea_electrodes = [(11:18)'; (21:28)'; (31:38)'; (41:48)'; (51:58)'; (61:68)'; (71:78)';(81:88)']; % electrode names
elNum=64;
% --------------- Property of the PLOT
binindex1=strfind(start_folder, 'bin');
binindex2=strfind(start_folder, '-');
binsize=str2num(start_folder(binindex1+3:binindex2(end)-1));
timeframeindex=strfind(start_folder, 'msec');
timeframe= str2num(start_folder(binindex2(end)+1:timeframeindex-1));
x=binsize*[1:timeframe/binsize];

coll = ['k','r','b','g', 'y']; % Colors of multiple plot
style=cell(4,1); % Useful if we want to change the style
style{1,1}='-'; % style{1,1}=':';
style{2,1}='-'; % style{2,1}='-';
style{3,1}='-'; % style{3,1}='--';
style{4,1}='-';
style{5,1}='-';

% -------------- START PROCESSING ------------
cd (start_folder)
name_dir=dir;
name_dir_cell=struct2cell(name_dir);
name_dir_cell=name_dir_cell(1,3:length(name_dir_cell(1,:)))'; % Only names of the directories - cell array

% Save in the array 'stimoli' the names of the stimulating electrodes
for i=1:fix(length(name_dir_cell)/num_stimel) % In the case of tetanus experiment, this number is 3.    
    stimoli(i)=str2num(name_dir_cell{i}(end-1:end));
end

for k=1:length(stimoli)
    scrsz = get(0,'ScreenSize');
    h=figure('Position',[1+100 scrsz(1)+100 scrsz(3)-200 scrsz(4)-200]);
    stimel= stimoli(k); % name of the stimulating electrodes - double
    
    for i = 1:elNum       % start cycling on the directories  
        electrode=mcmea_electrodes(i); % name of the considered electrode - double        
        [index]=findfolder(name_dir_cell, stimel);
        for j=1:length(index)
            folder_path= strcat (start_folder, filesep, name_dir_cell{index(j)});
            filename= strcat(name_dir_cell{index(j)}, '_', num2str(electrode), '.mat');
            if exist(fullfile(folder_path, filename))
                load (fullfile(folder_path, filename))
                graph_pos= lookuptable(find(lookuptable(:,1)==electrode),2);
                subplot(8,8,graph_pos)
                y=plot(x, psthcnt, 'LineStyle', style{j,1}, 'col', coll(j), 'LineWidth', 1.5);
                hold on
                axis ([0 psthend 0 binsize/2]) % Usually the Peak Detection window is 2 - to be modified!!!
                box off
                set(gca,'ytick',[]);
                set(gca,'xtick',[]);
            end
        end
        cd (start_folder) 
    end
    nome= strcat('cumPSTH_8x8grid_stim', num2str(stimel));
    cd(end_folder)
    saveas(y,nome,'jpg');
    % saveas(y,nome,'fig');
    %close all;  
end

EndOfProcessing (start_folder, 'Successfully accomplished');
clear all
